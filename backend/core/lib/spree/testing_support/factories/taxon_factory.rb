FactoryBot.define do
  factory :taxon, class: Spree::Taxon do
    sequence(:name) { |n| "taxon_#{n}" }
    taxonomy
    parent_id nil
  end
end
