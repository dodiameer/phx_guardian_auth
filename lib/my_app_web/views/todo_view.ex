defmodule MyAppWeb.TodoView do
  use MyAppWeb, :view
  alias MyAppWeb.TodoView

  def render("index.json", %{todos: todos}) do
    %{data: render_many(todos, TodoView, "todo.json")}
  end

  def render("show.json", %{todo: todo}) do
    %{data: render_one(todo, TodoView, "todo.json")}
  end

  def render("todo.json", %{todo: todo}) do
    %{id: todo.id,
      title: todo.title,
      content: todo.content,
      is_complete: todo.is_complete}
  end
end
