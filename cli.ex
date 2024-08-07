defmodule Issues.CLI do

  @default_count 4
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                                     aliases:  [ h:     :help ])

    case parse do
    { [ help: true ], _,           _ } -> :help
    { _, [ user, project, count ], _ } -> { user, project,
                                          String.to_integer(count) }
    { _, [ user, project ],        _ } -> { user, project, @default_count }

    _                                  -> :help
    end
  end
  def run(argv) do
    argv
    |> parse_args
    |> process
    end
  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
    end

  def process({user, project, _count}) do
      Issues.GithubIssues.fetch(user, project)
      |> decode_response()
      |> sort_into_descending_order()
    end
  def sort_into_descending_order(list_of_issues) do
      list_of_issues
      |> Enum.sort(fn i1, i2 ->
        i1["created_at"] >= i2["created_at"]
      end)
    end
  def decode_response({:ok, body}), do: body
  def decode_response({:error, error}) do
      IO.puts "Error fetching from Github: #{error["message"]}"
      System.halt(2)
    end
end
