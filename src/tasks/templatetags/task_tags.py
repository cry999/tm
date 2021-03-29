from typing import Any, Dict, List
from django.template import Library
from tasks.models import Task as TaskModel

register = Library()


@register.filter()
def task_tags(task: TaskModel) -> List[Dict[str, Any]]:
    return [
        {
            "content": "project:" + (str(task.project) or "---"),
            "classes": "task-project-tag",
        },
        {
            "content": "status:" + task.status,
            "classes": "task-status",
        },
    ]
