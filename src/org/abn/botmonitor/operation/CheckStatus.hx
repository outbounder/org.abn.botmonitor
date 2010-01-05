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
	private var httpThread:Thread;
	private var timeoutTimer:Timer;
	
	public override function execute(params:Hash<String>):String
	{		
		this.waitingResponsesCount = 0;
		this.responseBuffer = "";
		
		var monitorJids:List<Dynamic> = this.botContext.get("monitor.jid");
		for (jid in monitorJids)
		{
			this.waitingResponsesCount += 1;
			this.botContext.getXMPPContext().sendMessage(jid, "<statusReport/>", statusReportHandler);
		}
		
		this.httpThread = Thread.current();
		this.timeoutTimer = new Timer(5000);
		this.timeoutTimer.run = onTimeout;
		
		return Thread.readMessage(true);
	}
	
	private function onTimeout():Void
	{
		this.dispose("timeoutResponse");
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
		if(this.timeoutTimer != null)
			this.timeoutTimer.stop();
		this.timeoutTimer = null;
		
		if(this.httpThread != null)
			this.httpThread.sendMessage("<"+reason+">" + responseBuffer + "</"+reason+">");
		this.httpThread = null;
	}
	
}