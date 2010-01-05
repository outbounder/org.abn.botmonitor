package org.abn.botmonitor;

import org.abn.bot.operation.BotOperationFactory;
import org.abn.botmonitor.BotMonitor;
import org.abn.botmonitor.operation.Start;
import org.abn.botmonitor.operation.Stop;
import org.abn.botmonitor.operation.CheckStatus;

class BotMonitorOperationFactory extends BotOperationFactory
{	
	public function new(appContext:BotMonitor) 
	{
		super(appContext);
	}
}