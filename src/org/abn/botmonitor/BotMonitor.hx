package org.abn.botmonitor;

import org.abn.bot.operation.BotOperationFactory;
import org.abn.Context;
import org.abn.bot.BotContext;
import org.abn.neko.AppContext;

class BotMonitor extends BotContext
{	
	public function new(context:AppContext) 
	{
		super(context);
	}
	
	public override function getOperationFactory():BotOperationFactory
	{
		if (!this.has("operationFactory"))
			this.set("operationFactory", new BotMonitorOperationFactory(this));
		return this.get("operationFactory");
	}
}