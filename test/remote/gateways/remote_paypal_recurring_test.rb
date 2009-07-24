require 'test_helper'

class PaypalRecurringTest < Test::Unit::TestCase
  def setup
    Base.gateway_mode = :test
    
    @gateway = PaypalGateway.new(fixtures(:paypal_signature))

    @creditcard = CreditCard.new(
      :type                => "visa",
      :number              => "4381258770269608", # Use a generated CC from the paypal Sandbox
      :verification_value => "000",
      :month               => 1,
      :year                => Time.now.year + 1,
      :first_name          => 'Fred',
      :last_name           => 'Brooks'
    )
       
    @params = {
      # :order_id                => generate_unique_id,
      :email                   => 'buyer@jadedpallet.com',
      :billing_address         => { :name => 'Fred Brooks',
                                    :address1 => '1234 Penny Lane',
                                    :city => 'Jonsetown',
                                    :state => 'NC',
                                    :country => 'US',
                                    :zip => '23456'
                                  },
      :description            => 'Your Recurring Subscription Profile',
      :ip                     => '10.0.0.1',
      :periodicity            => :monthly,
      :starting_at            => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    }
      
    @amount = 1000
    
  end
  
  def test_successful_create_recurring_profile
    response = @gateway.recurring(@amount, @creditcard, @params)
    assert_success response
    assert response.params["profile_id"]
  end
  
  def test_create_recurring_profile_with_missing_amount
    response = @gateway.recurring(nil, @creditcard, @params)
    assert_failure response
  end
  
  def test_create_recurring_profile_with_missing_credit_card
    response = @gateway.recurring(@amount, nil, @params)
    assert_failure response
  end
  
end

class PaypalRecurringTestExistingProfile < Test::Unit::TestCase
  
  def setup
    Base.gateway_mode = :test
    
    @gateway = PaypalGateway.new(fixtures(:paypal_signature))

    @creditcard = CreditCard.new(
      :type                => "visa",
      :number              => "4381258770269608", # Use a generated CC from the paypal Sandbox
      :verification_value => "000",
      :month               => 1,
      :year                => Time.now.year + 1,
      :first_name          => 'Fred',
      :last_name           => 'Brooks'
    )
       
    @params = {
      :email                   => 'buyer@jadedpallet.com',
      :billing_address         => { :name => 'Fred Brooks',
                                    :address1 => '1234 Penny Lane',
                                    :city => 'Jonsetown',
                                    :state => 'NC',
                                    :country => 'US',
                                    :zip => '23456'
                                  },
      :description            => 'Your Recurring Subscription Profile',
      :ip                     => '10.0.0.1',
      :periodicity            => :monthly,
      :starting_at            => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    }
    
    @amount = 1000
    
    @profile_response = @gateway.recurring(@amount, @creditcard, @params)
    @profile_id = @profile_response.params["profile_id"]
    @params.merge!(:profile_id => @profile_id)
  end
  
  def teardown
    @gateway.cancel_recurring(@profile_id)
  end
  
  def test_successful_modify_recurring_profile
    response = @gateway.modify_recurring(@amount, @creditcard, @params.merge!(:description => "This is a changed profile", :comment => "Your profile has changed"))
    assert_success response
  end
  
  def test_successful_inquire_recurring_profile
    response = @gateway.recurring_inquiry(@profile_id)
    assert_success response
  end
  
  def test_successful_suspend_recurring_profile
    response = @gateway.suspend_recurring(@profile_id)
    assert_success response
  end
    
end

class PaypalRecurringTestCancelExistingProfile < Test::Unit::TestCase
  
  def setup
    Base.gateway_mode = :test
    
    @gateway = PaypalGateway.new(fixtures(:paypal_signature))

    @creditcard = CreditCard.new(
      :type                => "visa",
      :number              => "4381258770269608", # Use a generated CC from the paypal Sandbox
      :verification_value => "000",
      :month               => 1,
      :year                => Time.now.year + 1,
      :first_name          => 'Fred',
      :last_name           => 'Brooks'
    )
       
    @params = {
      :email                   => 'buyer@jadedpallet.com',
      :billing_address         => { :name => 'Fred Brooks',
                                    :address1 => '1234 Penny Lane',
                                    :city => 'Jonsetown',
                                    :state => 'NC',
                                    :country => 'US',
                                    :zip => '23456'
                                  },
      :description            => 'Your Recurring Subscription Profile',
      :ip                     => '10.0.0.1',
      :periodicity            => :monthly,
      :starting_at            => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    }
    
    @amount = 1000
    
    @profile_response = @gateway.recurring(@amount, @creditcard, @params)
    @profile_id = @profile_response.params["profile_id"]
    @params.merge!(:profile_id => @profile_id)
  end
  
  def test_successful_cancel_recurring_profile
    response = @gateway.cancel_recurring(@profile_id)
    assert_success response
  end
    
end