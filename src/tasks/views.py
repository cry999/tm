from typing import Any, Dict, Optional
from django.contrib.auth.mixins import LoginRequiredMixin
from django.db.models.query import QuerySet
from django.db.models.query_utils import Q
from django.http.response import HttpResponse, HttpResponseRedirect
from django.urls import reverse
from django.urls.base import reverse_lazy
from django.views.generic import FormView, ListView
from django.views.generic.edit import DeleteView, UpdateView

from tasks.forms import EditTaskForm, NewTaskForm
from tasks.models import Status, Task
from accounts.models import User
from projects.models import Project

# Create your views here.


class TaskListView(ListView, LoginRequiredMixin):
    model = Task
    context_object_name = "tasks"
    template_name = "tasks/index.html"

    STATUS_FILTER = "status"

    def get_queryset(self) -> QuerySet:
        user = self.request.user
        status = self.request.GET.get(self.STATUS_FILTER, Status.WIP)

        return (
            Task.objects.filter((Q(author=user) | Q(assignee=user)) & Q(status=status))
            .order_by("-priority", "-deadline", "-created_at", "-updated_at")
            .all()
        )

    def get_context_data(self, **kwargs: Any) -> Dict[str, Any]:
        data = super().get_context_data(**kwargs)
        data["statuses"] = Status.values
        return data


class NewTaskView(FormView, LoginRequiredMixin):
    template_name = "tasks/new.html"
    form_class = NewTaskForm

    def get_initial(self) -> Dict[str, Any]:
        initial = super().get_initial()

        parent = self.get_parent()
        initial["parent"] = parent
        initial["project"] = parent.project if parent else self.get_project()

        return initial

    def form_valid(self, form: NewTaskForm) -> HttpResponse:
        author: User = self.request.user
        name: str = form.data["name"]
        parent = self.get_parent(form=form)
        if parent:
            new_task = parent.create_subtask(author, name)
        else:
            new_task = Task.created_by(author, name)
            new_task.project = self.get_project(form=form)
        new_task.save()

        project = new_task.project
        if project is not None:
            return HttpResponseRedirect(
                reverse("projects:detail", kwargs={"pk": project.pk}),
            )

        return HttpResponseRedirect(reverse("tasks:index"))

    def get_project_id(self, form: NewTaskForm = None) -> Optional[str]:
        in_path = self.request.GET.get("project_id", None)
        if in_path:
            return in_path

        in_form = form and form.data.get("project", None)
        if in_form:
            return in_form

        return None

    def get_project(self, form: NewTaskForm = None) -> Optional[Project]:
        pk = self.get_project_id(form=form)
        if pk:
            return Project.objects.get(pk=pk)
        return None

    def get_parent_id(self, form: NewTaskForm = None) -> Optional[str]:
        in_path = self.kwargs.get("parent_id", None)
        if in_path:
            return in_path

        in_form = form and form.data.get("parent", None)
        if in_form:
            return in_form

        return None

    def get_parent(self, form: NewTaskForm = None) -> Optional[Task]:
        pk = self.get_parent_id(form=form)
        if pk:
            return Task.objects.get(pk=pk)
        return None


class EditTaskView(UpdateView, LoginRequiredMixin):
    template_name = "tasks/edit.html"
    form_class = EditTaskForm
    success_url = reverse_lazy("tasks:index")

    def get_queryset(self) -> QuerySet:
        user = self.request.user
        assert user.is_authenticated

        return Task.objects.filter(Q(author=user) | Q(assignee=user)).all()


class DeleteTaskView(DeleteView, LoginRequiredMixin):
    template_name = "tasks/confirm_delete.html"
    success_url = reverse_lazy("tasks:index")
    context_object_name = "task"

    def get_queryset(self) -> QuerySet:
        user = self.request.user
        assert user.is_authenticated

        return Task.objects.filter(Q(author=user) | Q(assignee=user)).all()
