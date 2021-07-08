defmodule MyApp.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string
      add :content, :string
      add :is_complete, :boolean, default: false
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false

      timestamps()
    end
  end
end
