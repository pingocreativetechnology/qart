defmodule QartWeb.PublicSiteTest do
  use QartWeb.FeatureCase, async: false

  import Qart.UserFixtures
  import Qart.ShoppingFixtures
  import Qart.InventoryFixtures

  def login_user(session, user) do
    session
    |> visit("/users/log_in")
    |> fill_in(text_field("Email"), with: user.email)
    |> fill_in(text_field("Password"), with: "passwordpassword")
    |> click(button("Log in"))
  end

  test "User registers", %{session: session} do
    session
    |> visit("/")
    |> click(link("Register"))
    |> fill_in(text_field("Email"), with: "user1@lvh.me")
    |> fill_in(text_field("Password"), with: "passwordpassword")
    |> click(button("Create an account"))
    |> assert_has(css("body", text: "Account created successfully")) # or whatever

    |> visit("/")
    |> click(link("Items"))
    |> assert_has(css("body", text: "Listing Items"))

    |> visit("/")
    |> click(link("Wallet"))

    |> assert_has(css("body", text: "Wallet"))
    |> assert_has(css("body", link: "All Wallets"))

    |> visit("/")
    |> click(link("Public"))
    |> assert_has(css("body", text: "Connect with other public users"))


    |> visit("/")
    |> click(link("Catalog"))

    |> visit("/")
    |> click(link("Activity stream"))
    |> assert_has(css("body", text: "created the invoice."))

    |> visit("/")
    |> click(link("Cart"))
    |> assert_has(css("body", text: "Cart"))

    # Profile
    |> visit("/")
    |> click(link("user1@lvh.me"))
    |> assert_has(css("body", text: "user1@lvh.me"))


    |> click(link("Shop"))
    |> assert_has(css("body", text: "user1@lvh.me's Store"))

    |> click(button("Tip"))
    |> assert_has(css("body", text: "Pay user1@lvh.me"))

    |> click(button("Ask"))
    |> assert_has(css("textarea[phx-blur='submit_ask']"))

    |> click(button("Post"))
    |> assert_has(css("form[phx-submit='create_post']"))
    |> click(css(".hero-x-mark-solid.h-5.w-5")) # close button

    |> click(link("Map"))
    |> assert_has(css("body", text: "Full screen"))

    |> click(link("Settings"))
    |> assert_has(css("body", text: "Account Settings"))

    |> click(link("Log out"))
    |> assert_has(css("body", text: "peer to peer commerce"))
    |> assert_has(css("body", text: "Your social network starts with you."))

    # |> QartWeb.FeatureCase.pause_here(30_000)

    # http://localhost:4002/items

    # |> fill_in(text_field("Email"), with: "user1@lvh.me")
    # |> fill_in(text_field("Password"), with: "passwordpassword")
    # |> click(button("Log in"))
    # |> assert_has(css("h1", text: "home")) # or whatever your home text is
    # |> visit("/about")
    # |> assert_has(css("h1", text: "About"))
    # |> visit("/public")
    # |> assert_has(css("h1", text: "Public"))
  end

  test "logs in", %{session: session} do
    user = user_fixture()

    session
    |> visit("/")
    |> click(link("Log in"))
    |> fill_in(text_field("Email"), with: user.email)
    |> fill_in(text_field("Password"), with: "passwordpassword")

    |> click(button("Log in"))
    |> assert_has(css("body", text: "Welcome back!"))
  end

  test "when logged in", %{session: session} do
    user = user_fixture()

    QartWeb.PublicSiteTest.login_user(session, user)
    |> visit("/")
  end

  test "set handle", %{session: session} do
    user = user_fixture()

    session
    |> visit("/users/log_in")
    |> fill_in(text_field("Email"), with: user.email)
    |> fill_in(text_field("Password"), with: "passwordpassword")
    |> click(button("Log in"))

    # |> QartWeb.FeatureCase.pause_here()
    |> visit("/handle/set")
    |> fill_in(text_field("Handle"), with: "broomstick")
    |> click(button("Save"))
    |> assert_has(css("body", text: "Handle set successfully!"))

    # |> QartWeb.FeatureCase.pause_here
    # |> QartWeb.FeatureCase.pause_here(30_000)

  end

  test "generate wallet", %{session: session} do
    user = user_fixture()

    session = login_user(session, user)
    |> visit("/")
    |> click(link("Wallet"))
    |> click(link("All Wallets"))
    |> click(button("Generate First Wallet"))
    |> assert_has(css("body", text: "Wallet generated successfully"))

    div = find(session, css("div[name='mnemonic']"))
    text = Wallaby.Element.text(div)

    word_count =
      text
      |> String.trim()
      |> String.split(~r/\s+/, trim: true)
      |> length()
    assert word_count == 12

    # refresh the page to see the wallet
    session
    |> visit("/wallets")
    |> click(css("a[name='wallet']"))
    |> assert_has(css("body", text: "Current Derivation Index: 0"))
    |> click(button("Generate New Address"))
    |> click(button("Generate New Address"))
    |> click(button("Generate New Address"))
    |> assert_has(css("li[name='address']", count: 3))
    # Refresh the page
    # Assert 3 addresses are showing
    |> assert_has(css("li[name='address']", count: 3))
    session
  end

  test "restore wallet and generate keys", %{session: session} do
    user = user_fixture()


    session = login_user(session, user)
    |> assert_has(css("body", text: "Welcome back!"))
    |> assert_has(css("body", text: "peer to peer commerce"))
    |> click(link("Wallet"))
    |> click(link("All Wallets"))
    |> click(button("Restore Wallet"))
    |> assert_has(css("body", text: "Load Test 12 words"))
    |> click(button("Load Test 12 words"))
    |> click(button("Submit"))
    # Restore wallet
    |> assert_has(css("body", text: "Wallet restored successfully"))
    |> visit("/wallets")
    |> click(link("Active Wallet"))
    |> click(link("All Wallets"))
    |> click((css("div[name='wallets'] a[name='wallet']")))

    # Make the wallet the default wallet
    |> click(button("Make this wallet default"))
    |> assert_has(css("body", text: "is now the default Wallet"))

    # Generate Keys
    |> click(button("Generate New Address"))
    |> click(button("Generate New Address"))
    |> click(button("Generate New Address"))
    |> assert_has(css("body", text: "mwqvASigS4AEAWGtHYcgV2xFVrADC4KaG4"))
    |> assert_has(css("body", text: "m/44'/236'/0'/0/1"))
    |> assert_has(css("body", text: "mpVjxzWwqLSgMnD2a6sfq64q24Vk2LTkBa"))
    |> assert_has(css("body", text: "m/44'/236'/0'/0/2"))
    |> assert_has(css("body", text: "myWhTtnRavhzkGzAcyBygMT88o3wX4D7mh"))
    |> assert_has(css("body", text: "m/44'/236'/0'/0/3"))
    |> QartWeb.FeatureCase.pause_here(50_000)

    session
  end

  test "craft tx", %{session: session} do
    user = user_fixture()

    login_user(session, user)
    |> visit("/wallets/")
    |> click(button("Generate First Wallet"))
    |> assert_has(css("body", text: "Wallet generated successfully"))
    |> visit("/wallets")
    |> click(css("a[name='wallet']"))
    |> assert_has(css("body", text: "Current Derivation Index: 0"))
    |> click(button("Generate New Address"))

    |> click(link("Craft a Tx"))
    # On /wallet/tx page
    |> assert_has(css("body", text: "Wallet ID"))
    |> assert_has(css("body", text: "Derivation Path"))
    |> assert_has(css("body", text: "Inputs"))
    |> assert_has(css("body", text: "Outputs"))
    |> assert_has(css("body", text: "1satOrdinal"))
    |> assert_has(css("body", text: "Additional Custom Outputs"))
    |> click(button("Update tx / Clickwrap"))
    |> assert_has(css("body", text: "Lock_time"))
    |> assert_has(css("body", text: "Outpoint"))
    |> assert_has(css("body", text: "Script"))
    |> assert_has(css("body", text: "Unsigned BSV Transaction"))

    # Contract validation
    |> assert_has(css("body", text: "Valid contract?"))
    |> assert_has(css("body", text: "false"))
    |> click(button("Validate"))
    |> assert_has(css("body", text: "true"))
    # |> QartWeb.FeatureCase.pause_here(50_000)
  end

  test "items", %{session: session} do
    user = user_fixture()
    cart = cart_fixture()
    item = item_fixture()
    item2 = item_fixture()
    item3 = item_fixture()
    item4 = item_fixture()
    item_fixture()
    item_fixture()
    item_fixture()

    session = login_user(session, user)
    |> visit("/catalog/")

    |> assert_has(css("div[name='item']", count: 7))
    |> click(css("div[name='item'][id='item-#{item2.id}'] a"))
    |> assert_has(css("body", text: "some name"))
    |> assert_has(css("body", text: "some description"))
    |> assert_has(css("body", text: "some status"))
    |> click(button("Add to Cart"))
    |> assert_has(css("body", text: "Added to cart!"))

    |> visit("/catalog/")
    |> click(css("div[name='item'][id='item-#{item3.id}'] a"))
    |> click(button("Add to Cart"))

    # View Cart
    |> visit("/cart/")
    |> assert_has(css("body", text: "Cart"))
    |> assert_has(css("body", text: "some name"))
    |> assert_has(css("body", text: "Order summary"))
    |> assert_has(css("body", text: "Available"))
    |> assert_has(css("body", text: "Cost of goods"))
    |> assert_has(css("body", text: "$241.00"))
    |> assert_has(css("body", text: "Sales tax"))
    |> assert_has(css("body", text: "18.08"))
    |> assert_has(css("body", text: "Excise Tax"))
    |> assert_has(css("body", text: "36.15"))
    |> assert_has(css("body", text: "Shipping"))
    |> assert_has(css("body", text: "5.00"))
    |> assert_has(css("body", text: "Total"))
    |> assert_has(css("body", text: "300.23"))

    |> click(css("li[name='cart-item'][item-id='item-#{item2.id}'] button[phx-click='remove_from_cart']"))

    # After removing an item
    # |> QartWeb.FeatureCase.pause_here(50_000)
    |> assert_has(css("body", text: "Cost of goods"))
    |> assert_has(css("body", text: "$120.50"))
    |> assert_has(css("body", text: "Sales tax"))
    |> assert_has(css("body", text: "9.04"))
    |> assert_has(css("body", text: "Excise Tax"))
    |> assert_has(css("body", text: "18.08"))
    |> assert_has(css("body", text: "Shipping"))
    |> assert_has(css("body", text: "5.00"))
    |> assert_has(css("body", text: "Total"))
    |> assert_has(css("body", text: "152.62"))
    # |> QartWeb.FeatureCase.pause_here(50_000)

    # Empty cart
    |> click(button("Remove all items from cart"))
    |> assert_has(css("body", text: "Cart emptied"))
    |> assert_has(css("body", text: "No items in cart"))

    # Re-add item
    |> visit("/catalog/")
    |> click(css("div[name='item'][id='item-#{item3.id}'] a"))
    |> click(button("Add to Cart"))
    |> visit("/cart/")

    # TODO CHECKOUT
    |> click(button("Checkout"))

    # Send payment to complete your order:
    # 1J12o2k964mJPTuS53Un7oJ2Hxo5ksYf4L
    ##
    ## What happens here?

    # User should have a public key.
    # ... or a public key function?
    # What are the characteristics and benefit of doing this?
    # With the public key's private key, the User can sign a message showing they own the address. ...
    # They 2nd user can verify a message based on the public address. --> Message + Key


    #
    # Bitcoin is sent from user's fungible UXTOs
    # A bitcoin transaction is built (using TxBuilder) by Qart for the Item(s) in the ShoppingCartTransaction
    # The target (to) address is passed to the Transaction.
    # The amount of Satoshis
    # Any special parameters
    # The user's wallet signs it
    #
    # Broadcast it
    # ... wait for it to confirm (and gracefully handle failures)
    #
    # Qart should have the full transaction, and not need to sync it from chain
    #
    # Qart could be refreshing addresses
    |> QartWeb.FeatureCase.pause_here(50_000)

    # Convert a Cart into a Transaction/Receipt / Object?
    # Person
    # has many Items in a Cart
    # each Item has price
    # the price per User is subject to tax
    #

    # session
    # |> QartWeb.FeatureCase.pause_here(50_000)
  end
end
