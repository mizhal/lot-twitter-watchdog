# Twitter Watchdog Component for Lord of the Tweets

This component (packaged as a ruby gem) implements the scanning and saving of tweet links, profile data, favs & retweets information gathered from twitter API.

As long as it remains convenient, every read interaction with Twitter API must be done only in this component. Write interactions could be added in the future, but as of now, they are not included in the scope of the project, and then it will be better to treat them as another component.

## Dependencies

* twitter gem
* TwitterRawProtocol ''catalog'', i.e, a logical interface wich provides access to data layer (whatever that layer would be).

## Architecture

Each major task assigned to the component (update twitter follower graph, update profile data, gather tweets, etc) is carried out by a single class that fulfills the so-called "IWatchdogTask" interface.

This interface is simple, a Task must have a method to start execution and a method to stop execution.

Execution: **execute**, this method must be a coroutine, i.e, it must yield the control eventually to allow the controller class to interleave tasks or to sleep the time required to not starve the API (twitter has a limit of request per time unit).

Stop: **stop** this method must stop the task. This method is not intended to be called from another process or thread, but from the yield block of execute coroutine. Therefore it should not deal with concurrency issues at all.

The controller class is called *Watchdog*. When a new instance of the class is created, it must be provided with a list of Tasks. 
When the method **run** is called on the Watchdog, each task of the lists will be sent "execute" and when this method yields control, Watchdog will sleep the amount of time required.

Each one of the tasks is expected to be correctly configured and initialized when passed to Watchdog. This stage of configuration and initialization is completely free for the developer to design and it is not constrained by any interface or rule.



