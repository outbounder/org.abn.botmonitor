package org.abn.botmonitor.operation;

import neko.Web;
import org.abn.bot.operation.BotOperation;
import org.abn.bot.operation.BotOperationListener;

class Stop extends BotOperation
{
	public override function execute(params:Hash<String>):String
	{
		if (!this.botContext.has("started"))
			return "not started";
			
		if (this.botContext.has("operationListener"))
		{
			var opListener:BotOperationListener = this.botContext.get("operationListener");
			opListener.stopListening();
			this.botContext.set("operationListener", null);
		}
			
		this.botContext.set("started", null);
		this.botContext.set("operationListener", null);
		this.botContext.closeXMPPConnection();
		
		Web.cacheModule(null);
		return "done";
	}
}