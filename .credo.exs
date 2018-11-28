%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "test/", "web/", "apps/"],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      color: true,
      checks: [
        {Credo.Check.Warning.LazyLogging, false}
      ]
    }
  ]
}