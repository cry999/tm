from typing import Any, Dict, Iterable
from django.template import Library
from tasks.models import Task as TaskModel

register = Library()


@register.filter()
def task_tags(task: TaskModel) -> Iterable[Dict[str, Any]]:
    if task.project:
        yield {
            "content": "project:" + str(task.project or "---"),
            "classes": "task-project-tag",
        }
    yield {
        "content": "status:" + task.status,
        "classes": "task-status",
    }
