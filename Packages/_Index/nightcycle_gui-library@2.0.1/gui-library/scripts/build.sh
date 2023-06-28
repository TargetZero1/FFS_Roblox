pseudo-enum build test.project.json
style-guide build out/StyleGuide.luau -dark
py scripts/edit_style_guide.py
rojo sourcemap test.project.json --output sourcemap.json
stylua out