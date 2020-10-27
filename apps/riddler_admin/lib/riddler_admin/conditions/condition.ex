defmodule RiddlerAdmin.Conditions.Condition do
  use RiddlerAdmin.Schema

  alias RiddlerAdmin.Workspaces.Workspace

  @id_opts [prefix: "cnd", rand_size: 8]

  @derive {Jason.Encoder, only: [:id, :key, :source, :instructions]}
  schema "conditions" do
    field :id, Ecto.UXID, @id_opts ++ [primary_key: true, autogenerate: true]
    # field :workspace_id, Ecto.UXID
    belongs_to :workspace, Workspace

    field :key, :string
    field :source, :string
    field :instructions, Ecto.PredicatorInstructions

    timestamps()
  end

  def id_opts(), do: @id_opts

  @doc false
  def changeset(condition, attrs) do
    condition
    |> cast(attrs, [:key, :source])
    |> validate_required([:key, :source])
    # |> validate_source(source)
    |> compile()
  end

  @doc false
  def create_changeset(condition, attrs, workspace_id) do
    condition
    |> changeset(attrs)
    |> put_change(:workspace_id, workspace_id)
    |> validate_required([:workspace_id])
  end

  defp compile(changeset) do
    case get_change(changeset, :source) do
      nil -> changeset
      source -> compile_instructions(changeset, source)
    end
  end

  defp compile_instructions(changeset, nil), do: changeset

  defp compile_instructions(changeset, source) when is_binary(source),
    do:
      changeset
      |> put_change(:instructions, Predicator.compile!(source))
end
