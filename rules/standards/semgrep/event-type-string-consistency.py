from enum import Enum


class EventType(Enum):
    AGENT_STARTED = "agent_started"
    AGENT_COMPLETED = "agent_completed"
    TASK_FAILED = "task_failed"


# ruleid: event-type-string-consistency
event_type = "agent_started"

# ruleid: event-type-string-consistency
event_type = "task_failed"

# ok: event-type-string-consistency
event_type = EventType.AGENT_STARTED

# ok: event-type-string-consistency
event_type = EventType.TASK_FAILED
