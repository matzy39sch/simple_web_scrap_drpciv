defmodule WebScrap do
  @moduledoc """
  Documentation for `WebScrap`.
  """

  @spec create_csv(binary) :: :ok | {:error, atom}
  def create_csv( url) do
    SimpleBar.start(:ok,1000)
    table_header = [
        ["Nr.", "Intrebare" , "Raspunsuri correcte" , "Raspunsuri incorrecte" , "Explicatie" ],
        ["",    ""          , ""                    , ""                      , ""          ]
      ]
    file = File.open!("G:/Prog/Elixir/web_scrap/test_output/test.csv", [:write, :utf8])

    table_header
    |> CSV.encode
    |> Enum.each(&IO.write(file, &1))

    call_grab(url, file)

    File.close(file)
  end

  @spec call_grab(binary, any, any) :: :ok
  def call_grab( url, file, nr_list \\ []) do
    case grab(url, nr_list) do
      %{
        next_url: next_url,
        nr_list: new_nr_list,
        csv: csv
      } ->

        csv
        |> CSV.encode
        |> Enum.each(&IO.write(file, &1))

        case URI.new(next_url) do
          {:ok, _} ->
            call_grab( next_url, file, new_nr_list)
            # :ok
          {:error, _} ->
            IO.puts("Done")
        end

      %{next_url: nil} ->
        IO.puts("Done")


    end
  end

  @spec grab(binary, any) :: %{
          :next_url => any,
          optional(:csv) => [[...], ...],
          optional(:nr_list) => nonempty_maybe_improper_list
        }
  def grab(url, nr_list \\ []) do
    case HTTPoison.get!(url) do
      %HTTPoison.Response{status_code: 200 , body: body} ->
        {:ok, document} = Floki.parse_document(body)

        title = document
        |> Floki.find("div.w3-dark-grey")

        nr = document
        |> Floki.find("div.w3-dark-grey div")
        |> Floki.text()



        title = title
        |> Floki.text()
        |> String.replace( nr, "")
        # IO.puts("Title: #{title}")

        String.replace("1,2,3", ",", "")
        explanation = document
        |> Floki.find("fieldset.w3-round-medium")
        |> Floki.text()

        # IO.puts("Explanation: #{explanation}")

        raspunsuri = document
        |> Floki.find("div.intrebari-raspunsuri")

        # IO.puts("raspunsuri: #{inspect(raspunsuri)}")

        incorrecte =
          raspunsuri
          |> Enum.filter(fn {"div", [_ , {"style", " background-color:#33FF33;"}], _text} -> false
            _ ->
              true
            end)
          |> Floki.text()
          |> remove_delimiters()


        # IO.puts("incorrect raspunsuri: #{inspect(incorrecte)}")

        correct =
          raspunsuri
          |> Enum.filter( fn {"div", [_ , {"style", " background-color:#33FF33;"}], _text} ->
                true
              _ ->
                false
            end)
          |> Floki.text()
          |> remove_delimiters()



        # IO.puts("correct raspunsuri: #{inspect(correct)}")
        next_url = document
        |> Floki.find("div.w3-container p a")
        |> Floki.attribute("href")
        |> List.last()


        # IO.puts("next_url: #{next_url}")
        int_nr =
          case Integer.parse(nr) do
            {int_nr, _} ->
              int_nr
            _ ->
              1
          end

        case int_nr in nr_list do
          true ->
            %{
              next_url: nil
            }
          false ->
            nr_list = [int_nr | nr_list]
            SimpleBar.step(:ok, int_nr,1000)

            IO.puts("Nr: #{inspect(int_nr)}")

            %{
              next_url: next_url,
              nr_list: nr_list,
              csv: [[nr, title, correct, incorrecte, explanation]]
            }
        end

      _ ->
        %{
          next_url: nil
        }
    end
  end

  @spec remove_delimiters(binary) :: binary
  def remove_delimiters(text) do
    text
    |> String.replace( ",", "")
    |> String.replace( ";", "")
    |> String.replace( ".", "")
  end
end
