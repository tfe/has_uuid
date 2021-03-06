require File.dirname(__FILE__) + '/test_helper'

class Widget < ActiveRecord::Base
  has_uuid
end

class Thingy < ActiveRecord::Base
  has_uuid :auto => false
end

class Blidget < ActiveRecord::Base
  has_uuid :column => :token
end

class HasUuidTest < Test::Unit::TestCase
  
  def test_method_assign_uuid
    @widget = Widget.new
    @widget.assign_uuid
    assert_nothing_raised { UUIDTools::UUID.parse(@widget.uuid) }
  end
  
  def test_method_assign_uuid!
    @widget = Widget.new
    @widget.assign_uuid!
    @widget.reload
    assert_nothing_raised { UUIDTools::UUID.parse(@widget.uuid) }
  end
  
  def test_method_uuid_valid?
    @widget = Widget.new(:uuid => UUIDTools::UUID.random_create.to_s)
    assert @widget.uuid_valid?
    @widget = Widget.new(:uuid => "not a uuid")
    assert @widget.uuid_invalid?
  end
  
  
  def test_should_assign_uuid_on_create
    @widget = Widget.new
    assert_nil @widget.uuid
    @widget.save
    @widget.reload
    assert_nothing_raised { UUIDTools::UUID.parse(@widget.uuid) }
  end
  
  def test_should_not_assign_uuid_if_already_valid
    test_uuid = UUIDTools::UUID.random_create.to_s
    @widget = Widget.new(:uuid => test_uuid)
    @widget.save
    @widget.reload
    assert_equal(test_uuid, @widget.uuid)
  end
  
  def test_should_assign_uuid_if_current_not_valid
    # nil
    @widget = Widget.new
    @widget.save
    @widget.reload
    assert_nothing_raised { UUIDTools::UUID.parse(@widget.uuid) }
    
    # blank
    @widget = Widget.new(:uuid => "")
    @widget.save
    @widget.reload
    assert_nothing_raised { UUIDTools::UUID.parse(@widget.uuid) }
    
    # non-uuid string
    @widget = Widget.new(:uuid => "not a uuid")
    @widget.save
    @widget.reload
    assert_nothing_raised { UUIDTools::UUID.parse(@widget.uuid) }
  end
  
  def test_should_always_assign_uuid_when_forced
    original_uuid = UUIDTools::UUID.random_create.to_s
    @widget = Widget.new(:uuid => original_uuid)
    @widget.assign_uuid(:force => true)
    test_uuid = @widget.uuid
    @widget.save
    @widget.reload
    assert_equal(test_uuid, @widget.uuid)
    assert_not_equal(original_uuid, @widget.uuid)
  end
  
  def test_uuid_should_be_reassignable
    @widget = Widget.new
    @widget.save
    @widget.reload
    assert @widget.uuid_valid?
    
    new_uuid = UUIDTools::UUID.random_create.to_s
    @widget.uuid = new_uuid
    @widget.save
    @widget.reload
    assert @widget.uuid_valid?
    assert_equal(new_uuid, @widget.uuid)
  end
  
  
  
  def test_uuids_should_not_autoassign
    @thingy = Thingy.new
    @thingy.save
    @thingy.reload
    assert_nil @thingy.uuid
  end
  
  
  
  def test_uuid_column_should_be_customizable
    @blidget = Blidget.new
    @blidget.save
    uuid = @blidget.token
    @blidget.reload
    
    assert @blidget.token.present?
    assert_nothing_raised { @found_blidget = Blidget.find_by_id_or_uuid(uuid) }
    assert_equal(@blidget, @found_blidget)
  end
  
  
  
  def test_finding_by_id_or_uuid
    @widget = Widget.new
    @widget.save
    @widget.reload
    
    assert_equal(@widget, Widget.find_by_id_or_uuid(@widget.uuid))
    assert_equal(@widget, Widget.find_by_id_or_uuid(@widget.id))
  end
  
  def test_finding_by_id_or_uuid_with_bang_raises_exception
    @widget = Widget.new
    @widget.save
    @widget.reload
    arbitrary_uuid = UUIDTools::UUID.random_create.to_s
    
    assert_raise ActiveRecord::RecordNotFound do
      Widget.find_by_id_or_uuid!('garbage')
    end
    assert_raise ActiveRecord::RecordNotFound do
      Widget.find_by_id_or_uuid!(arbitrary_uuid).inspect
    end
    
    assert_nothing_raised { Widget.find_by_id_or_uuid!(@widget.uuid) }
    assert_equal(@widget, Widget.find_by_id_or_uuid!(@widget.uuid))
  end
  
  def test_finding_by_id_or_uuid_with_custom_uuid_column
    @blidget = Blidget.new
    @blidget.save
    @blidget.reload
    
    assert_equal(@blidget, Blidget.find_by_id_or_uuid(@blidget.token))
    assert_equal(@blidget, Blidget.find_by_id_or_uuid(@blidget.id))
  end
  
end
