package org.abn.botmonitor.operation;

import jabber.client.Roster;
import jabber.Ping;
import jabber.XMPPError;
import org.abn.bot.operation.BotOperation;
import org.abn.bot.operation.BotOperationListener;
import org.abn.neko.xmpp.XMPPContext;
import org.abn.botmonitor.Main;
import org.abn.botmonitor.BotMonitorOperationFactory;
import neko.Web;
import xmpp.Message;

class Start extends BotOperation
{		
	public override function execute(params:Hash<String>):String
	{
		if (this.botContext.has("started"))
			return "already started";
			
		var xmppContext:XMPPContext = this.botContext.getXMPPContext();
		xmppContext.openConnection(true, onConnected, onDisconnected, onConnectFailed);
		
		Web.cacheModule(Main.handleRequests);
		this.botContext.set("started", true);
		return "done";
	}
	
	private function onConnectFailed(reason:Dynamic):Void
	{
		this.botContext.set("started", null);
		trace("xmpp connect failed "+reason);
	}
	
	private function onConnected():Void
	{
		this.botContext.getXMPPContext().getConnection().createMessageListener(incomingMessagesHandler, true);
		
		var monitorJids:List<Dynamic> = this.botContext.get("monitor.jid");
		for (jid in monitorJids)
			this.botContext.getXMPPContext().getConnection().sendMessage(jid, "<statusReport/>");
		
		trace("botmonitor connected");
	}
	
	private function incomingMessagesHandler(msg:Message):Void
	{
		trace(msg.from + " -> " + msg.body.split("&lt;").join("<").split("&gt;").join(">"));
	}
	
	private function onDisconnected():Void
	{
		if (this.botContext.has("started"))
		{
			trace("trying to reconnect...");
			var xmppContext:XMPPContext = this.botContext.getXMPPContext();
			xmppContext.openConnection(false, onConnected, onDisconnected);
		}
	}
}