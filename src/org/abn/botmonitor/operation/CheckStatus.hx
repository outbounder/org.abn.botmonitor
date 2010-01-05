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
	private var messageListener:MessageListener;
	
	public override function execute(params:Hash<String>):String
	{
		this.waitingResponsesCount = 0;
		this.responseBuffer = "";
		this.messageListener = this.botContext.getXMPPContext().getConnection().createMessageListener(incomingMessagesHandler, true);
		
		var monitorJids:List<Dynamic> = this.botContext.get("monitor.jid");
		for (jid in monitorJids)
		{
			this.waitingResponsesCount += 1;
			this.botContext.getXMPPContext().getConnection().sendMessage(jid, "<statusReport/>");
		}
		
		this.httpThread = Thread.current();
		this.timeoutTimer = new Timer(5000);
		this.timeoutTimer.run = onTimeout;
		
		return Thread.readMessage(true);
	}
	
	private function onTimeout():Void
	{
		this.timeoutTimer.stop();
		this.messageListener.listen = false;
		this.httpThread.sendMessage("<timeoutResponse>" + responseBuffer + "</timeoutResponse>");
	}
	
	private function incomingMessagesHandler(msg:Message):Void
	{
		var response:String = "<report><from>"+msg.from+"</from><status>"+msg.body.split("&lt;").join("<").split("&gt;").join(">")+"</status></report>";
		responseBuffer += response;
		this.waitingResponsesCount -= 1;
		
		if (waitingResponsesCount <= 0)
		{
			this.timeoutTimer.stop();
			this.messageListener.listen = false;
			this.httpThread.sendMessage("<response>" + responseBuffer + "</response>");
		}
	}
	
}