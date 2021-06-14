defmodule MyApp.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyApp.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "todos" do
    field :title, :string
    field :content, :string
    field :is_complete, :boolean, default: false
    # field :user_id, :binary_id
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :content, :is_complete])
    |> validate_required([:title, :is_complete])
  end
end
