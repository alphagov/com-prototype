RSpec.feature "Allocate content to other content auditors", type: :feature do
  let!(:discworld) do
    create(
      :organisation,
      title: "Discworld",
    )
  end

  let!(:me) do
    create(
      :user,
      name: "Terry Pratchett",
      organisation: discworld,
    )
  end

  context "There are other auditors in my organisation" do
    let!(:vimes) do
      create(
        :user,
        name: "Commander Vimes",
        organisation: discworld,
      )
    end

    let!(:tiffany) do
      create(
        :user,
        name: "Tiffany Aching",
        organisation: discworld,
      )
    end

    scenario "List content auditors of same organisation" do
      visit audits_allocations_path

      options = [
        "Me",
        "Anyone",
        "No one",
        "Commander Vimes",
        "Tiffany Aching",
      ]
      expect(page).to have_select("allocated_to", options: options)
    end

    scenario "Allocate content to other content auditors" do
      create(
        :content_item,
        title: "The Wee Free Men",
        content_id: "wee-free-men",
        primary_publishing_organisation: discworld,
      )

      create(
        :content_item,
        title: "Going Postal",
        primary_publishing_organisation: discworld,
      )

      visit audits_allocations_path

      check option: "wee-free-men"

      select "Tiffany Aching", from: "allocate_to"
      click_on "Assign"

      expect(page).to have_content("1 items allocated to Tiffany Aching")

      select "Tiffany Aching", from: "allocated_to"
      click_on "Apply filters"

      expect(page).to have_content("The Wee Free Men")
      expect(page).to_not have_content("Going Postal")
    end
  end
end
