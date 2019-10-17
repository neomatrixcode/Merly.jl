using Documenter, Merly

makedocs(format = Documenter.HTML(),
         modules = [Merly],
         sitename = "Merly.jl"
         )
deploydocs(
	repo = "https://github.com/codeneomatrix/Merly.jl"
	#devbranch = "master",
    #devurl = "dev",
    #versions = ["stable" => "v^", "v#.#", "devurl" => devurl]
    )
