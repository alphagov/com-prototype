RSpec.feature "Allocate multiple content items", type: :feature do
  let!(:novelists) do
    create(
      :organisation,
      title: "Novelists",
    )
  end

  let!(:me) do
    create(
      :user,
      name: "Jane Austen",
      organisation: novelists,
    )
  end

  context "There are three unallocated content items belonging to my organisation" do
    let!(:pride_and_prejudice) do
      create(
        :content_item,
        title: "Pride and Prejudice",
        content_id: "pride-and-prejudice",
        primary_publishing_organisation: novelists,
      )
    end

    let!(:emma) do
      create(
        :content_item,
        title: "Emma",
        content_id: "emma",
        primary_publishing_organisation: novelists,
      )
    end

    let!(:sense_and_sensibility) do
      create(
        :content_item,
        title: "Sense and Sensibility",
        content_id: "sense-and-sensibility",
        primary_publishing_organisation: novelists,
      )
    end

    scenario "Allocate content within current page" do
      visit audits_allocations_path

      check option: "emma"
      check option: "sense-and-sensibility"

      select "Me", from: "allocate_to"
      click_on "Assign"

      expect(page).to have_content("2 items allocated to Jane Austen")

      select "Me", from: "allocated_to"
      click_on "Apply filters"

      expect(page).to_not have_content("Pride and Prejudice")
      expect(page).to have_content("Emma")
      expect(page).to have_content("Sense and Sensibility")

      select "No one", from: "allocated_to"
      click_on "Apply filters"

      expect(page).to have_content("Pride and Prejudice")
      expect(page).to_not have_content("Emma")
      expect(page).to_not have_content("Sense and Sensibility")
    end

    scenario "Allocate using the batch input" do
      visit audits_allocations_path

      select "Me", from: "allocate_to"
      fill_in "batch_size", with: "2"
      click_on "Assign"

      expect(page).to have_content("2 items allocated to Jane Austen")
    end

    scenario "Allocation when filtering by organisation using filter results" do
      create(:organisation, title: "Painters")

      visit audits_allocations_path
      unselect "Novelists", from: "Organisations"
      select "Painters", from: "Organisations"
      click_on "Apply filters"

      select "Me", from: "allocate_to"
      fill_in "batch_size", with: "4"
      click_on "Assign"

      expect(page).to have_content("0 items allocated to Jane Austen")
    end

    scenario "Allocate selecting individual items" do
      visit audits_allocations_path

      check option: "emma"
      check option: "sense-and-sensibility"

      select "Me", from: "allocate_to"
      click_on "Assign"

      expect(page).to have_content("2 items allocated to Jane Austen")
    end

    scenario "Allocate 0 content items" do
      visit audits_allocations_path

      select "Me", from: "allocate_to"
      click_on "Assign"

      expect(page).to have_content("0 items allocated to Jane Austen")
    end
  end
end
