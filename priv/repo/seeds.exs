alias Qart.Repo
alias Qart.Inventory.Item
alias Qart.Accounts.User
alias Qart.Accounts.Favorite
alias Qart.Accounts.Follow
alias Qart.Posts.Post
require Faker

# USERS =======================================================================
1..10
|> Enum.each(fn i ->
  email = "user#{i}@lvh.me"
  password = "passwordpassword"
  handle = Faker.Internet.user_name()

  user_changeset =
    %User{}
    |> User.registration_changeset(%{
      email: email,
      password: password,
      handle: handle
    })

  case Repo.insert(user_changeset) do
    {:ok, user} -> IO.puts("Created user: #{user.email} with handle: #{user.handle}")
    {:error, changeset} -> IO.inspect(changeset.errors)
  end
end)

users = Repo.all(User)

IO.puts("✅ Seeded 10 users successfully!")

# ITEMS =======================================================================
available_items = [
  %{
    name: "Vintage Leather Wallet",
    description: "A stylish and durable leather wallet with multiple compartments.",
    price: Decimal.new("49.99"),
    tags: ["leather", "fashion", "wallet"],
    status: "available",
    images: ["/uploads/seeds/item-wallet.png"]
  },
  %{
    name: "Wireless Bluetooth Headphones",
    description: "Noise-canceling headphones with high-quality sound and long battery life.",
    price: Decimal.new("89.99"),
    tags: ["electronics", "audio", "headphones"],
    status: "available",
    images: ["/uploads/seeds/item-headphones.png"]
  },
  %{
    name: "Handmade Ceramic Mug",
    description: "A beautifully crafted ceramic mug, perfect for coffee or tea.",
    price: Decimal.new("14.99"),
    tags: ["kitchen", "ceramics", "mug"],
    status: "available",
    images: ["/uploads/seeds/item-mug.png"]
  },
  %{
    name: "Wooden Chess Set",
    description: "A handcrafted wooden chess set with detailed pieces and a foldable board.",
    price: Decimal.new("59.99"),
    tags: ["games", "wood", "chess"],
    status: "sold",
    images: ["/uploads/seeds/item-chess-board.png"]
  },
  %{
    name: "Smartphone Stand",
    description: "A sleek and minimalist smartphone stand for desks and nightstands.",
    price: Decimal.new("19.99"),
    tags: ["accessory", "phone", "stand"],
    status: "available",
    images: ["/uploads/seeds/item-phonestand.png"]
  },
  %{
    name: "Vintage Typewriter",
    description: "A fully functional vintage typewriter, great for collectors and writers.",
    price: Decimal.new("199.99"),
    tags: ["vintage", "writing", "typewriter"],
    status: "available",
    images: ["/uploads/seeds/item-typewriter.png", "/uploads/typewriter2.jpg"]
  },
  %{
    name: "LED Desk Lamp",
    description: "A modern LED desk lamp with adjustable brightness and a USB charging port.",
    price: Decimal.new("39.99"),
    tags: ["lighting", "home", "desk lamp"],
    status: "available",
    images: ["/uploads/seeds/item-lamp.png"]
  },
  %{
    name: "Black Twill Hat",
    description: "A basic black hat.",
    price: Decimal.new("19.99"),
    tags: ["hat", "black", "twill"],
    status: "available",
    images: ["/uploads/seeds/item-hat.png"]
  },
  %{
    name: "Nightstand dresser",
    description: "A walnut nightstand dresser, bed-height.",
    price: Decimal.new("199.99"),
    tags: ["walnut", "wood", "bedroom", "nightstand", "dresser"],
    status: "available",
    images: ["/uploads/seeds/item-dresser.png"]
  }
]

# Create Items (2-10 per user)
Enum.each(users, fn user ->
  num_items = Enum.random(1..10)

  # available_item = available_items |> Enum.random
  # # Qart.debug(user)
  # available_item = Map.put(available_item, :user_id, user.id)
  # # Qart.debug(available_item)

  # item_changeset = %Item{} |> Item.changeset(available_item)
  # Qart.debug(item_changeset)

  1..num_items
  |> Enum.each(fn _ ->
    available_item = available_items |> Enum.random
    available_item = Map.put(available_item, :user_id, user.id)
    item_changeset = %Item{} |> Item.changeset(available_item)

    Repo.insert(item_changeset)
  end)
end)


IO.puts("✅ Seeded Items successfully!")

# FOLLOWS AND FAVORITES ========================================================
items = Repo.all(Item)

# Create Favorite Items (2-7 per user)
Enum.each(users, fn user ->
  num_favorites = Enum.random(2..7)

  1..num_favorites
  |> Enum.each(fn _ ->
    favorite_changeset = %Favorite{}
    |> Favorite.changeset(%{
      user_id: user.id,
      item_id: Enum.random(items).id
    })

    Repo.insert(favorite_changeset)
  end)
end)

# Create Follows (2-5 per user)
Enum.each(users, fn user ->
  num_follows = Enum.random(2..5)
  possible_follow_ids = Enum.map(users, & &1.id) -- [user.id] # Avoid self-follow

  1..num_follows
  |> Enum.each(fn _ ->
    if possible_follow_ids != [] do
      followed_user_id = Enum.random(possible_follow_ids)

      follow_changeset = %Follow{}
      |> Follow.changeset(%{user_id: user.id, followed_user_id: followed_user_id})

      Repo.insert(follow_changeset)
    end
  end)
end)

# Create Posts (2-10 per user)
Enum.each(users, fn user ->
  num_posts = Enum.random(1..10)

  1..num_posts
  |> Enum.each(fn _ ->
    post_changeset = %Post{}
    |> Post.changeset(%{
      user_id: user.id,
      content: Faker.Lorem.paragraph()
    })

    Repo.insert(post_changeset)
  end)
end)
