# encoding: utf-8
module Infoboxer
  describe Node do
    let(:document){
      Parser.parse(%Q{
      Test in first ''paragraph''
      {| some=table
      |With
      * cool list
      * And deep test
      |}
      }.strip.gsub(/\n\s+/m, "\n"))
    }
    
    describe :lookup do
      context 'without any args' do
        subject{
          document.lookup
        }
        it{should be_kind_of(Nodes)}
        its(:count){should > 10}
      end
      
      context 'with block' do
        subject{
          document.lookup{|n| n.is_a?(Text) && n.text =~ /test/i}
        }

        it{should be_kind_of(Nodes)}
        it{should == [
          Text.new('Test in first '),
          Text.new('And deep test') 
        ]}
      end

      context 'by class' do
        subject{document.lookup(Table)}
        its(:count){should == 1}
      end

      context 'by class & fields' do
        subject{
          document.lookup(Text, text: /test/i)
        }

        it{should be_kind_of(Nodes)}
        it{should == [
          Text.new('Test in first '),
          Text.new('And deep test') 
        ]}
      end

      context 'everything at once' do
        subject{
          document.lookup(Text, text: /test/i){|n| n.text.length == 13}
        }

        it{should be_kind_of(Nodes)}
        it{should == [
          Text.new('And deep test') 
        ]}
      end
    end

    describe :lookup_child do
      let(:cell){document.lookup(TableCell).first}

      context 'direct child only' do
        subject{cell.lookup_child(Text)}

        its(:count){should == 1}
        its(:first){should == Text.new('With')}
      end

      context 'indirect child' do
        subject{cell.lookup_child(ListItem)}
        
        it{should be_empty}
      end
    end

    describe 'chain of lookups' do
    end

    describe :lookup_parent do
    end
  end
end