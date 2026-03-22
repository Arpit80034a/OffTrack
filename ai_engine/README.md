# Intelligent Schedule Manager - AI Engine

A Python Flask microservice that generates optimized daily schedules using a priority × urgency scoring algorithm.

## Setup

```bash
pip install -r requirements.txt
python app.py
```

The server starts on port **5001**.

## API

### `POST /generate-schedule`

**Request Body:**
```json
{
  "tasks": [
    {
      "task_id": "abc123",
      "title": "Complete report",
      "priority": "high",
      "deadline": "2025-12-20T17:00:00Z",
      "estimated_duration": 90
    }
  ],
  "preferences": {
    "work_start_time": "09:00",
    "work_end_time": "17:00",
    "break_duration": 15,
    "focus_level": "medium"
  }
}
```

**Response:**
```json
{
  "schedule": [
    {
      "task_id": "abc123",
      "title": "Complete report",
      "start_time": "09:00",
      "end_time": "10:30",
      "priority": "high",
      "score": 27
    }
  ],
  "total_items": 1,
  "message": "Successfully scheduled 1 tasks"
}
```

## Algorithm

1. **Score** each task: `priority_weight × urgency_factor`
2. **Sort** by composite score (highest first)
3. **Allocate** time slots within work hours with breaks
4. **Adjust** durations based on focus level
