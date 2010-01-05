﻿package org.abn.botmonitor.operation;

import neko.Web;
import org.abn.bot.operation.BotOperation;

class Stop extends BotOperation
{
	public override function execute(params:Hash<String>):String
	{
		if (!this.botContext.has("started"))
			return "not started";
			
		this.botContext.set("started", null);
		this.botContext.set("operationListener", null);
		this.botContext.closeXMPPConnection();
		
		Web.cacheModule(null);
		return "done";
	}
}