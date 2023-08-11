# Katello Architecture

## Event Queue
The Event Queue enables asynchronous event processing with a few other requirements:

### Requirements

#### Deduplication
Certain operations in Katello may trigger a flurry of events that would cause the same operation to be executed several times in a row. One example is generating Content Host Errata applicability. When an action triggering applicability generation occurs, an event is placed on the queue. Several applicability events may be queued for the same host in a brief period. The next time the Event Queue is drained it will calculate applicability for that host only once and remove the duplicate events afterward since their action has already been completed.

#### Scheduling
Certain operations need to happen at some point in the future from the time an event is queued. Events can be marked with a timestamp indicating when they should be handled. Until that point they'll remain untouched in the queue. One example of this is removal of a Content Host's Qpid queue (Katello Agent) which happens ten minutes after unregistering. If the host re-registers in that window its queue will be preserved.

#### Retrying
Certain events which might fail can be marked as needing to be retried. The functionality works on top of event scheduling. Each event can configure its retry wait individually. The Event Queue controls the total elapsed time that any event can be retried but doesn't limit the number of retries in that window.

### Operation
The Event Queue is drained by the Event Daemon which is different subsystem. Draining occurs every three seconds. The drain interval was chosen to strike a balance between timely handling of events and gaining benefit from deduplication. The Daemon runs the Event Queue [here](https://github.com/Katello/katello/blob/master/app/services/katello/event_monitor/poller_thread.rb).

### Implementation
The logic is consolidated in the [Event Queue Service](https://github.com/Katello/katello/blob/master/app/services/katello/event_queue.rb). It ultimately controls all ingress/egress of the [Katello::Event](https://github.com/Katello/katello/blob/master/app/models/katello/event.rb) table. All events must be [registered](https://github.com/Katello/katello/blob/master/lib/katello/engine.rb#L225-L230) in order to be processed.
