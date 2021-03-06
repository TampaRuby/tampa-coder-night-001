require File.dirname(__FILE__) + '/../lib/turtle'

describe Turtle do
  let(:input) { File.read(File.dirname(__FILE__) + '/../simple.logo') }
  let(:turtle) do
    canvas_size = input.split("\n").shift
    Turtle.new(canvas_size)
  end

  describe '#tracks' do
    let(:commands) { input.split("\n")[2..-1] }
    let(:expected_output) { File.read(File.dirname(__FILE__) + '/../simple_out.txt') }

    it 'returns the completed turtle tracks' do
      turtle.tracks.should_not == expected_output
      turtle.process_commands(commands)
      turtle.tracks.should == expected_output
    end
  end

  describe '#rotate' do
    it 'reduces the angle for negative amounts' do
      turtle.angle = 180
      turtle.rotate(-90)
      turtle.angle.should == 90
    end

    it 'increases the angle for positive amounts' do
      turtle.angle = 90
      turtle.rotate(90)
      turtle.angle.should == 180
    end

    it 'corrects the angle when rotating more than 360 degrees' do
      turtle.angle = 315
      turtle.rotate(90)
      turtle.angle.should == 45
    end

    it 'corrects the angle when rotating less than 0 degrees' do
      turtle.angle = 45
      turtle.rotate(-90)
      turtle.angle.should == 315
    end

    it 'normalizes an angle of 360 to 0' do
      turtle.angle = 315
      turtle.rotate(45)
      turtle.angle.should == 0
    end

  end

  describe '#move' do
    let(:starting_position) { { :x => 5, :y => 5 } }

    before(:each) do
      turtle.position = starting_position
    end

    describe 'directions' do
      it 'moves north when angle is 0' do
        turtle.angle = 0
        2.times { turtle.move }
        turtle.position.should == { :x => 5, :y => 3 }
      end

      it 'moves north east when angle is 45' do
        turtle.angle = 45
        2.times { turtle.move }
        turtle.position.should == { :x => 7, :y => 3 }
      end

      it 'moves east when angle is 90' do
        turtle.angle = 90
        2.times { turtle.move }
        turtle.position.should == { :x => 7, :y => 5 }
      end

      it 'moves south east when angle is 135' do
        turtle.angle = 135
        2.times { turtle.move }
        turtle.position.should == { :x => 7, :y => 7 }
      end

      it 'moves south when angle is 180' do
        turtle.angle = 180
        2.times { turtle.move }
        turtle.position.should == { :x => 5, :y => 7 }
      end

      it 'moves south west when angle is 225' do
        turtle.angle = 225
        2.times { turtle.move }
        turtle.position.should == { :x => 3, :y => 7 }
      end

      it 'moves west when angle is 270' do
        turtle.angle = 270
        2.times { turtle.move }
        turtle.position.should == { :x => 3, :y => 5 }
      end

      it 'moves north west when angle is 315' do
        turtle.angle = 315
        2.times { turtle.move }
        turtle.position.should == { :x => 3, :y => 3 }
      end
    end

    describe 'trails' do
      it 'marks each position for the given distance going straight' do
        turtle.angle = 0
        2.times { turtle.move }
        turtle.grid.rows[4][5].should == 'X '
        turtle.grid.rows[3][5].should == 'X '
      end

      it 'marks each position for the given distance going diagonally' do
        turtle.angle = 45
        2.times { turtle.move }
        turtle.grid.rows[4][6].should == 'X '
        turtle.grid.rows[3][7].should == 'X '
      end
    end
  end

  describe '#commands' do
    it 'responds to LT, RT, FD, BK, REPEAT' do
      turtle.respond_to?(:LT).should be_true
      turtle.respond_to?(:RT).should be_true
      turtle.respond_to?(:FD).should be_true
      turtle.respond_to?(:BK).should be_true
      turtle.respond_to?(:REPEAT).should be_true
    end

    it 'responds to left, right, forward, back, repeat via aliases' do
      turtle.method(:left).should    == turtle.method(:LT)
      turtle.method(:right).should   == turtle.method(:RT)
      turtle.method(:forward).should == turtle.method(:FD)
      turtle.method(:back).should    == turtle.method(:BK)
      turtle.method(:repeat).should  == turtle.method(:REPEAT)
    end
  end

  describe '#process_command' do
    it 'calls left(90) for "LT 90"' do
      turtle.should_receive('LT').with(90)
      turtle.send(:process_command, "LT 90")
    end

    it 'calls right(90) for "RT 90"' do
      turtle.should_receive('RT').with(90)
      turtle.send(:process_command, "RT 90")
    end

    it 'calls forward(90) for "LT 90"' do
      turtle.should_receive('FD').with(90)
      turtle.send(:process_command, "FD 90")
    end

    it 'calls back(90) for "LT 90"' do
      turtle.should_receive('BK').with(90)
      turtle.send(:process_command, "BK 90")
    end

    it 'calls repeat(2, ["FD 5", "RT 45"]) for "REPEAT 2 [ FD 5 RT 45 ]"' do
      turtle.should_receive('REPEAT').with(2, ["FD 5", "RT 45"])
      turtle.send(:process_command, "REPEAT 2 [ FD 5 RT 45 ]")
    end
  end

  describe '#parse_command' do
    it 'returns the [direction, degree] for angle rotations' do
      turtle.send(:parse_command, 'RT 135').should == ['RT', 135]
      turtle.send(:parse_command, 'LT 90').should == ['LT', 90]
    end

    it 'returns the [direction, distance] for movements' do
      turtle.send(:parse_command, 'FD 5').should == ['FD', 5]
      turtle.send(:parse_command, 'BK 20').should == ['BK', 20]
    end

    it 'returns [action, iterations, commands] for repeats' do
      command = 'REPEAT 2 [ RT 90 FD 15 ]'
      expected_output = ['REPEAT', 2, ['RT 90', 'FD 15']]
      turtle.send(:parse_command, command).should == expected_output
    end
  end

  describe '#extract_commands' do
    it 'returns any comamnds a string might have' do
      commands = "RT 90 FD 15 RT 135"
      turtle.send(:extract_commands, commands).should == ['RT 90', 'FD 15', 'RT 135']
    end
  end

end

