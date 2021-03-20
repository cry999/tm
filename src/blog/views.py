from django.contrib.auth.mixins import LoginRequiredMixin
from django.db.models.query import QuerySet
from django.http.response import HttpResponse, HttpResponseRedirect
from django.urls import reverse, reverse_lazy
from django.views.generic import CreateView, DeleteView, DetailView, ListView
from django.views.generic.edit import UpdateView

from blog.forms import EditPostForm, NewPostForm
from blog.models import Post


class DetailPostView(DetailView, LoginRequiredMixin):
    model = Post
    template_name = "blog/detail.html"
    context_object_name = "post"


class NewPostView(CreateView, LoginRequiredMixin):
    model = Post
    template_name = "blog/new.html"
    form_class = NewPostForm

    def form_valid(self, form: NewPostForm) -> HttpResponse:
        post = form.save(commit=False)
        post.author = self.request.user
        post.save()
        return HttpResponseRedirect(reverse("blog:detail", kwargs={"pk": post.pk}))


class EditPostView(UpdateView, LoginRequiredMixin):
    model = Post
    template_name = "blog/edit.html"
    form_class = EditPostForm
    context_object_name = "post"

    def get_queryset(self) -> QuerySet:
        return self.model.objects.filter(author=self.request.user).all()

    def get_success_url(self) -> str:
        assert self.object is not None
        return reverse("blog:detail", kwargs={"pk": self.object.pk})


class ListPostView(ListView, LoginRequiredMixin):
    model = Post
    template_name = "blog/index.html"
    context_object_name = "posts"

    def get_queryset(self) -> QuerySet:
        signed_in_user = self.request.user
        return (
            self.model.objects.filter(author=signed_in_user)
            .all()
            .order_by("-created_at")
        )


class DeletePostView(DeleteView, LoginRequiredMixin):
    template_name = "blog/confirm_delete.html"
    success_url = reverse_lazy("blog:index")
    context_object_name = "post"

    def get_queryset(self) -> QuerySet:
        user = self.request.user
        assert user.is_authenticated

        return Post.objects.filter(author=user).all()
