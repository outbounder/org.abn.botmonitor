package org.abn.botmonitor.operation;

import neko.vm.Thread;
import util.Timer;
import jabber.client.Roster;
import jabber.Ping;
import jabber.XMPPError;
import org.abn.bot.operation.BotOperation;
import org.abn.neko.xmpp.XMPPContext;
import org.abn.botmonitor.Main;
import org.abn.botmonitor.BotMonitorOperationFactory;
import neko.Web;
import xmpp.Message;

class Start extends BotOperation
{		
	private var thread:Thread;
	
	public override function execute(params:Hash<String>):String
	{
		if (this.botContext.has("started"))
			return "already started";
			
		this.botContext.openXMPPConnection(onConnected, onConnectFailed, onDisconnected);
		
		Web.cacheModule(Main.handleRequests);
		this.botContext.set("started", true);
		this.thread = Thread.current();
		return Thread.readMessage(true);
	}
	
	private function onConnectFailed(reason:Dynamic):Void
	{
		this.botContext.set("started", null);
		trace("xmpp connect failed " + reason);
		this.thread.sendMessage("xmpp connection failed:"+reason);
	}
	
	private function onConnected():Void
	{		
		trace("botmonitor connected");
		this.thread.sendMessage("done");
	}
	
	private function onDisconnected():Void
	{
		if (this.botContext.has("started"))
		{
			trace("trying to reconnect...");
			this.botContext.openXMPPConnection(onConnected, onConnectFailed, onDisconnected);
		}
	}
}