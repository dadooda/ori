module Sample
  module BasicExtension
    module Mo
      def public_meth
        true
      end

      protected
      def protected_meth
        true
      end

      private
      def private_meth
        true
      end
    end

    class Klass
      extend Mo
    end

    module OtherMo
      extend Mo
    end
  end
end
