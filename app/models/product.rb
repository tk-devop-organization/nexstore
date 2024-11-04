class Product < ApplicationRecord
  has_many_attached :images

  # Validations
  validates :name, presence: true
  validates :description, presence: true, length: { maximum: 1000 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :acceptable_images

  private

  # Custom validation for images
  def acceptable_images
    return unless images.attached?

    images.each do |image|
      # if image.blob.byte_size > 5.megabytes
      #   errors.add(:images, "each image should be less than 5MB")
      # end

      acceptable_types = ["image/jpeg", "image/png"]
      unless acceptable_types.include?(image.blob.content_type)
        errors.add(:images, "must be a JPEG or PNG")
      end
    end
  end
end
