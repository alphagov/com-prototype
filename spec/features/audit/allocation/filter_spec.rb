RSpec.feature "Filter content by allocated content auditor", type: :feature do
  around(:each) do |example|
    Feature.run_with_activated(:auditing_allocation) { example.run }
  end

  let!(:current_user) { User.first }

  scenario "Filter allocated content" do
    another_user = create(:user)
    item1 = create :content_item, title: "content item 1"
    item2 = create(:content_item, title: "content item 2")
    create(:content_item, title: "content item 3")

    create(:allocation, content_item: item1, user: current_user)
    create(:allocation, content_item: item2, user: another_user)

    visit audits_path

    expect(page).to have_selector(".nav")
    expect(page).to have_selector("#sort_by")

    expect(page).to have_content("content item 1")
    expect(page).to have_content("content item 2")

    select "Me", from: "allocated_to"
    click_on "Apply filters"
    expect(page).to have_content("content item 1")
    expect(page).to_not have_content("content item 2")

    select "No one", from: "allocated_to"
    click_on "Apply filters"
    expect(page).to_not have_content("content item 1")
    expect(page).to_not have_content("content item 2")
    expect(page).to have_content("content item 3")

    select "Anyone", from: "allocated_to"
    click_on "Apply filters"
    expect(page).to have_content("content item 1")
    expect(page).to have_content("content item 2")
    expect(page).to have_content("content item 3")
  end

  scenario "Does not change filer status after user has allocated content" do
    create :content_item, title: "content item 1"
    item2 = create(:content_item, title: "content item 2")
    item3 = create(:content_item, title: "content item 3")

    create(:allocation, content_item: item2, user: current_user)

    visit audits_allocations_path

    select "No one", from: "allocated_to"
    click_on "Apply filters"

    check option: item3.content_id
    select "Me", from: "allocate_to"
    click_on "Go"

    expect(page).to_not have_content("content item 2")
    expect(page).to_not have_content("content item 3")

    expect(page).to have_select("allocated_to", selected: "No one")
  end

  scenario "Filter content allocated to other content auditor" do
    user = create(:user, name: "John Smith")
    item1 = create :content_item, title: "content item 1"
    create :allocation, user: user, content_item: item1
    create :content_item, title: "content item 2"

    visit audits_allocations_path

    expect(page).to have_content("content item 1")
    expect(page).to have_content("content item 2")

    select "John Smith", from: "allocated_to"
    click_on "Apply filters"

    expect(page).to have_content("content item 1")
    expect(page).to_not have_content("content item 2")
  end
end
