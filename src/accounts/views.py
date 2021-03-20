from django.contrib.auth import login, logout
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse
from django.http.request import HttpRequest
from django.http.response import HttpResponseNotAllowed, HttpResponseRedirect
from django.shortcuts import render
from django.urls import reverse
from django.views.generic import FormView

from accounts.forms import UserCreationForm, UserSignInForm

# Create your views here.


class SignUpFormView(FormView):
    template_name = "accounts/signup.html"
    form_class = UserCreationForm

    def form_valid(self, form: UserCreationForm) -> HttpResponse:
        form.save()
        return HttpResponseRedirect(reverse("accounts:index"))


class SignInFormView(FormView):
    template_name = "accounts/signin.html"
    form_class = UserSignInForm

    def form_valid(self, form: UserSignInForm) -> HttpResponse:
        next_url = self.request.GET.get("next", reverse("accounts:index"))
        user = form.get_user()
        login(self.request, user)
        return HttpResponseRedirect(next_url)


@login_required
def index(request: HttpRequest) -> HttpResponse:
    if request.method != "GET":
        return HttpResponseNotAllowed(["GET"])

    user = request.user
    return render(
        request,
        "accounts/index.html",
        context={
            "user": user,
        },
    )


def signout(request: HttpRequest) -> HttpResponse:
    signed_in_user = request.user
    if signed_in_user is not None and signed_in_user.is_authenticated:
        logout(request)
    return HttpResponseRedirect(reverse("index"))
