module Saas
  class ChargesController < Saas::ApplicationController
    include ::HuBoard::AccountHelpers

    def create
      begin
        @repo_owner = gh.users(params[:id])
        @repo_owner['email'] = params[:email]

        query = Queries::CouchCustomer.get(@repo_owner["id"], couch)
        plan_doc = QueryHandler.exec(&query)
        plan_doc = account_exists?(plan_doc) ?
          plan_doc[:rows].first.value : create_new_account(gh.user, @repo_owner)

        customer = Stripe::Customer.retrieve(plan_doc.id)
        if plan_doc[:trial] && plan_doc.trial != "available"
          customer.update_subscription({
            plan: params[:plan][:id],
            card: params[:card][:id],
            trial_end: 'now'
          })

          invoices = Stripe::Invoice.all(customer: customer.id)
          if invoices.first
            invoices.first.pay unless invoices.first.closed
          end
        else
          customer.subscriptions.create({
            plan: params[:plan][:id],
            card: params[:card][:id]
          })
        end

        if !params[:coupon].nil? && !params[:coupon].empty?
          customer.coupon = params[:coupon]
        end
        customer.save

        plan_doc.stripe.customer = customer
        plan_doc.billing_email = params[:email]
        plan_doc.trial = "expired"
        couch.customers.save plan_doc

        @account = JSON.parse(customer.to_json)
        @data = {
          billing_email: params[:email]
        }

        render json: { success: true, card: customer["cards"]["data"].first, discount: customer.discount}
      rescue Stripe::StripeError => e
        render json: e.json_body, status: 422
      end
    end
  end
end
