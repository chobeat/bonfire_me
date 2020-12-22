defmodule Bonfire.Me.Web.SwitchUserController do

  use Bonfire.Web, :controller
  alias Bonfire.Data.Identity.Account
  alias Bonfire.Me.Identity.{Accounts, Users}
  alias Bonfire.Common.Web.Misc

  @doc "A listing of users in the account."
  def index(%{assigns: the}=conn, params),
    do: index(the[:current_account_users], the[:current_account], conn, params)

  defp index([], _, conn, params) do
    conn
    |> put_flash(:info, "Hey there! Let's fill out your profile!")
    |> redirect(to: Routes.create_user_path(conn, :index) <> Misc.copy_go(params))
  end

  defp index([_|_]=users, _, conn, params) do
    conn
    |> assign(:current_account_users, users)
    |> assign(:go, Misc.go_query(conn))
    |> live_render(UsersLive)
  end

  defp index(nil, %Account{}=account, conn, params),
    do: index(Users.by_account(account), account, conn, params)

  defp index(nil, _account, _conn, _params) do
    Logger.error("[SwitchUserController.index] Missing :current_account")
    throw :missing_current_account
  end

  @doc "Switch to a user, if permitted."
  def show(conn, %{"id" => username} = params),
    do: show(Users.for_switch_user(username, conn.assigns.account_id), conn, params)

  defp show({:ok, user}, conn, params) do
    conn
    |> put_session(:user_id, user.id)
    |> put_flash(:info, "Welcome back, @#{user.character.username}!")
    |> redirect(to: Misc.go_where?(conn, params, Routes.home_path(conn, :index)))
  end

  defp show({:error, _}, conn, params) do
    conn
    |> put_flash(:error, "You can only become users in your account.")
    |> redirect(to: Routes.switch_user_path(conn, :index) <> Misc.copy_go(params))
  end

end
