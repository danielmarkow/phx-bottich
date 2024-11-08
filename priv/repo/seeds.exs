# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Bottich.Repo.insert!(%Bottich.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Bottich.BottichLink
alias Bottich.Repo
alias Bottich.BottichLists.List

testlist = Repo.insert!(%List{
  name: "Search Engines",
  description: "ways to search the web"
})

links = [
  %{link: "https://www.google.de", description: "google it"},
  %{link: "https://www.bing.de", description: "bing it"},
  %{link: "https://www.duckduckgo.com", description: "duck it"},
]

for link <- links do
  BottichLink.create_link(link, testlist)
end
