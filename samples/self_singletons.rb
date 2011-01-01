module Sample
  # Singletons declared via <tt>self.</tt> are in fact always public.
  module SelfSingletons
    module Mo
      def self.public_meth
        true
      end

      protected
      def self.protected_meth
        true
      end

      private
      def self.private_meth
        true
      end
    end

    class Klass
      def self.public_meth
        true
      end

      protected
      def self.protected_meth
        true
      end

      private
      def self.private_meth
        true
      end
    end
  end
end
