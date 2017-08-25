RSpec.feature "Auditing a content item", type: :feature do
  let!(:content_item) do
    create(
      :content_item,
      title: "Flooding",
      description: "All about flooding.",
      base_path: "/flooding",
      publishing_app: "whitehall",
    )
  end

  let!(:user) { create(:user) }

  def answer_question(question, answer)
    find('p', text: question)
      .first(:xpath, '..//..')
      .choose(answer)
  end

  def expect_answer(question, answer)
    label_element = find('p', text: question)
                      .first(:xpath, "..//..//input[@type='radio'][@checked='checked']//..")

    expect(label_element).to have_content(answer)
  end

  scenario "auditing a content item" do
    visit content_item_audit_path(content_item)

    expect(page).to_not have_selector(".nav")

    expect(page).to have_link("Flooding", href: "https://gov.uk/flooding")
    expect(page).to have_content("All about flooding.")

    expect(page).to have_link("Open in Whitehall Publisher")

    expect(page).to have_content("Do these things need to change?")

    answer_question "Title", "No"
    answer_question "Summary", "Yes"
    answer_question "Page detail", "No"
    fill_in "Notes", with: "something"

    click_on "Save"
    expect(page).to have_content("Please answer Yes or No to each of the questions.")

    answer_question "Attachments", "Yes"
    answer_question "Document type", "No"
    answer_question "Is the content out of date?", "Yes"
    answer_question "Should the content be removed?", "Yes"
    answer_question "Is this content very similar to other pages?", "Yes"
    fill_in "URLs of similar pages", with: "something"

    click_on "Save"
    expect(page).to have_content("Success: Saved successfully.")

    expect_answer "Title", "No"
    expect_answer "Summary", "Yes"
    expect_answer "Page detail", "No"
    expect_answer "Attachments", "Yes"
    expect_answer "Document type", "No"
    expect_answer "Is the content out of date?", "Yes"
    expect_answer "Should the content be removed?", "Yes"
    expect_answer "Is this content very similar to other pages?", "Yes"
    expect(find_field("URLs of similar pages").value).to eq("something")
    expect(find_field("Notes").value).to eq("something")

    answer_question "Attachments", "Yes"
    answer_question "Document type", "No"
    answer_question "Is the content out of date?", "Yes"

    click_on "Save"
    expect(page).to have_content("Success: Saved successfully.")

    expect_answer "Title", "No"
    expect_answer "Summary", "Yes"
    expect_answer "Page detail", "No"
    expect_answer "Attachments", "Yes"
    expect_answer "Document type", "No"
    expect_answer "Is the content out of date?", "Yes"
  end
end
