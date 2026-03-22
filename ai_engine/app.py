from flask import Flask, request, jsonify
from flask_cors import CORS
from scheduler import generate_optimized_schedule

app = Flask(__name__)
CORS(app)


@app.route('/', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({
        'service': 'Intelligent Schedule Manager - AI Engine',
        'version': '1.0.0',
        'status': 'running'
    })


@app.route('/generate-schedule', methods=['POST'])
def generate_schedule():
    """
    Generate an optimized schedule.

    Expects JSON body:
    {
        "tasks": [...],
        "preferences": {
            "work_start_time": "09:00",
            "work_end_time": "17:00",
            "break_duration": 15,
            "focus_level": "medium"
        }
    }
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No data provided'}), 400

        tasks = data.get('tasks', [])
        preferences = data.get('preferences', {})

        if not tasks:
            return jsonify({'schedule': [], 'message': 'No tasks to schedule'}), 200

        schedule = generate_optimized_schedule(tasks, preferences)

        return jsonify({
            'schedule': schedule,
            'total_items': len(schedule),
            'message': f'Successfully scheduled {len(schedule)} tasks'
        })

    except Exception as e:
        print(f'Error generating schedule: {e}')
        return jsonify({'error': 'Failed to generate schedule'}), 500


if __name__ == '__main__':
    print('🤖 AI Engine starting on port 5001...')
    app.run(host='0.0.0.0', port=5001, debug=True)
