defmodule MyAppWeb.TodoController do
  use MyAppWeb, :controller

  alias MyApp.Todos
  alias MyApp.Todos.Todo

  action_fallback MyAppWeb.FallbackController

  def index(conn, _params) do
    user = ControllerHelpers.current_user(conn)
    todos = Todos.list_todos(user)
    render(conn, "index.json", todos: todos)
  end

  def create(conn, %{"todo" => todo_params}) do
    user = ControllerHelpers.current_user(conn)
    with {:ok, %Todo{} = todo} <- Todos.create_todo(user, todo_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.todo_path(conn, :show, todo))
      |> render("show.json", todo: todo)
    end
  end

  def show(conn, %{"id" => id}) do
    user = ControllerHelpers.current_user(conn)
    todo = Todos.get_todo!(user, id)
    render(conn, "show.json", todo: todo)
  end

  def update(conn, %{"id" => id, "todo" => todo_params}) do
    user = ControllerHelpers.current_user(conn)
    todo = Todos.get_todo!(user, id)

    with {:ok, %Todo{} = todo} <- Todos.update_todo(todo, todo_params) do
      render(conn, "show.json", todo: todo)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = ControllerHelpers.current_user(conn)
    todo = Todos.get_todo!(user, id)

    with {:ok, %Todo{}} <- Todos.delete_todo(todo) do
      send_resp(conn, :no_content, "")
    end
  end
end
