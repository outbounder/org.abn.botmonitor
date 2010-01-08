/**
 * ...
 * @author outbounder
 */

package org.abn.botmonitor.operation;
import jabber.MessageListener;
import neko.vm.Thread;
import org.abn.bot.operation.BotOperation;
import util.Timer;
import xmpp.Message;

class CheckStatus extends BotOperation
{
    private var waitingResponsesCount:Int;
	private var responseBuffer:String;
	private var thread:Thread;
	
	public override function execute(params:Hash<String>):String
	{		
		this.waitingResponsesCount = 0;
		this.responseBuffer = "";
		this.thread = Thread.current();
		
		var monitorJids:List<Dynamic> = this.botContext.get("monitor.jid");
		for (jid in monitorJids)
		{
			this.waitingResponsesCount += 1;
			this.botContext.getXMPPContext().sendMessage(jid, "<statusReport/>", statusReportHandler, timeoutHandler);
		}
		
		return Thread.readMessage(true);
	}
	
	private function timeoutHandler(from:String):Void
	{
		var response:String = "<timeout><from>"+from+"</from></timeout>";
		responseBuffer += response;
		
		this.waitingResponsesCount -= 1;
		if (waitingResponsesCount <= 0)
			this.dispose("response");
	}
	
	private function statusReportHandler(from:String, msg:String):Void
	{
		var response:String = "<report><from>"+from+"</from><status>"+msg.split("&lt;").join("<").split("&gt;").join(">")+"</status></report>";
		responseBuffer += response;
		
		this.waitingResponsesCount -= 1;
		if (waitingResponsesCount <= 0)
			this.dispose("response");
	}
	
	private function dispose(reason:String):Void
	{
		if(this.thread != null)
			this.thread.sendMessage("<"+reason+">" + responseBuffer + "</"+reason+">");
		this.thread = null;
	}
	
}