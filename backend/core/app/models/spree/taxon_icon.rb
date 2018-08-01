module Spree
  class TaxonIcon < Asset
    has_attached_file :attachment,
                      styles: { mini: '32x32>', normal: '128x128>' },
                      default_style: :mini,
                      url: '/spree/taxons/:viewable_id/:style/:basename.:extension',
                      path: ':rails_root/public/spree/taxons/:viewable_id/:style/:basename.:extension',
                      default_url: '/assets/default_taxon.png'

    validates_attachment :attachment,
                         content_type: { content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif'] }
  end
end
