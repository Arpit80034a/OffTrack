from datetime import datetime, timedelta
from dateutil import parser as date_parser


def calculate_urgency(deadline_str):
    """Calculate urgency score based on deadline proximity."""
    try:
        deadline = date_parser.parse(deadline_str)
        now = datetime.now()
        if deadline.tzinfo:
            now = now.replace(tzinfo=deadline.tzinfo)
        hours_remaining = (deadline - now).total_seconds() / 3600
        if hours_remaining <= 0:
            return 10
        elif hours_remaining <= 24:
            return 9
        elif hours_remaining <= 48:
            return 7
        elif hours_remaining <= 72:
            return 5
        elif hours_remaining <= 168:
            return 3
        else:
            return 1
    except Exception:
        return 5


def get_priority_weight(priority):
    """Convert priority string to numerical weight."""
    weights = {'high': 3, 'medium': 2, 'low': 1}
    return weights.get(priority, 2)


def parse_time(time_str):
    """Parse time string to minutes from midnight."""
    parts = time_str.split(':')
    return int(parts[0]) * 60 + int(parts[1])


def format_time(minutes):
    """Convert minutes from midnight to HH:MM format."""
    hours = minutes // 60
    mins = minutes % 60
    return f"{hours:02d}:{mins:02d}"


def generate_optimized_schedule(tasks, preferences):
    """
    Generate an optimized daily schedule based on tasks, priorities, and user preferences.

    Algorithm:
    1. Score each task by priority × urgency
    2. Sort tasks by composite score (highest first)
    3. Allocate time slots within work hours, respecting break durations
    4. Return ordered schedule with start/end times

    Args:
        tasks: list of task dicts with title, priority, deadline, estimated_duration, task_id
        preferences: dict with work_start_time, work_end_time, break_duration, focus_level

    Returns:
        list of schedule items with task_id, title, start_time, end_time, priority
    """
    if not tasks:
        return []

    # Parse preferences
    work_start = parse_time(preferences.get('work_start_time', '09:00'))
    work_end = parse_time(preferences.get('work_end_time', '17:00'))
    break_duration = int(preferences.get('break_duration', 15))
    focus_level = preferences.get('focus_level', 'medium')

    # Adjust durations based on focus level
    focus_multiplier = {'low': 1.3, 'medium': 1.0, 'high': 0.85}
    multiplier = focus_multiplier.get(focus_level, 1.0)

    # Score and sort tasks
    scored_tasks = []
    for task in tasks:
        priority_weight = get_priority_weight(task.get('priority', 'medium'))
        urgency = calculate_urgency(task.get('deadline', ''))
        composite_score = priority_weight * urgency
        scored_tasks.append((composite_score, task))

    scored_tasks.sort(key=lambda x: x[0], reverse=True)

    # Build schedule
    schedule = []
    current_time = work_start

    for score, task in scored_tasks:
        raw_duration = int(task.get('estimated_duration', 60))
        duration = int(raw_duration * multiplier)

        # Check if task fits in remaining work hours
        if current_time + duration > work_end:
            # Try to fit partially or skip
            remaining = work_end - current_time
            if remaining >= 30:  # At least 30 minutes
                duration = remaining
            else:
                break

        start = format_time(current_time)
        end = format_time(current_time + duration)

        schedule.append({
            'task_id': task.get('task_id', ''),
            'title': task.get('title', 'Untitled'),
            'start_time': start,
            'end_time': end,
            'priority': task.get('priority', 'medium'),
            'score': score,
        })

        current_time += duration + break_duration

        if current_time >= work_end:
            break

    return schedule
