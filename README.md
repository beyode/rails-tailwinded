## Rails Tailwinded

This template will add [TailwindCss 2](https://tailwindcss.com/) to your rails application and apply default styles to your scaffolds.

### Installation
Create a new rails application with this template: -
```
rails new my_app_name -m https://raw.githubusercontent.com/beyode/rails-tailwinded/main/template.rb
```
Or reference the template locally if you have cloned the repo

```
rails new my_app_name -m /path/to/rails-tailwinded/template.rb
```

### Generating a Scaffold
New generated scaffold view will include tailwind styles
```
rails g scaffold Employee name phone city
```

### Sample screenshots

__Index Page__

![Inde page](/sample/index.png)

__Edit page__

![Edit page](/sample/edit.png)

__Show page__

![Show page](/sample/show.png)
