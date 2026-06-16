require "rails_helper"

RSpec.describe Product, type: :model do
  describe "validations" do
    it "is valid with all required attributes" do
      expect(build(:product)).to be_valid
    end

    it "is invalid without a name" do
      expect(build(:product, name: nil)).not_to be_valid
    end

    it "is invalid with a zero price" do
      expect(build(:product, price: 0)).not_to be_valid
    end

    it "is invalid with negative stock" do
      expect(build(:product, stock_count: -1)).not_to be_valid
    end
  end

  describe ".in_stock" do
    it "returns only products with stock > 0" do
      in_stock  = create(:product, stock_count: 5)
      out_stock = create(:product, stock_count: 0)
      expect(Product.in_stock).to     include(in_stock)
      expect(Product.in_stock).not_to include(out_stock)
    end
  end

  describe "#decrement_stock!" do
    let(:product) { create(:product, stock_count: 3) }

    it "decrements stock by the given quantity" do
      product.decrement_stock!(2)
      expect(product.reload.stock_count).to eq(1)
    end

    it "raises when quantity exceeds available stock" do
      expect { product.decrement_stock!(4) }.to raise_error("Insufficient stock")
      expect(product.reload.stock_count).to eq(3)
    end

    it "is atomic under concurrent access (row-level lock)" do
      # Two threads each try to buy the last 3 units; exactly one should succeed.
      successes = Concurrent::AtomicFixnum.new(0)
      failures  = Concurrent::AtomicFixnum.new(0)

      threads = 2.times.map do
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            Product.find(product.id).decrement_stock!(3)
            successes.increment
          rescue RuntimeError
            failures.increment
          end
        end
      end
      threads.each(&:join)

      expect(successes.value).to eq(1)
      expect(failures.value).to  eq(1)
      expect(product.reload.stock_count).to eq(0)
    end
  end
end
