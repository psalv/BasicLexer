


class String

  # Determines if a string represents a numeric value.
  # If the value is non-numeric the value will be 0, which is why we perform the self == '0' check.
  def is_a_int?
    self.equal_zero? || (self.to_i != 0) ? true : false
  end

  # Returns the index of the beginning of a comment if it exists.
  def is_a_comment?
    index = 0
    self.each_char do |c|
      index += 1
      if c.is_comment?
        return index
      end
    end
    index = 0
  end

  # Determines if the string is a comment.
  def is_comment?
    self == '#'
  end

  # Determines if a string is equivalent to the numeric zero.
  def equal_zero?
    self.each_char do |c|
      if c != '0'
        return false
      end
    end
    true
  end

end

class Array
  def print
    rtn = ''
    self.each {|i| rtn = rtn ++ (i.to_s + ', ')}
    puts rtn
  end
end


def findSpecial(str)
  special = {'(' => [], ')' => [], ',' => [], ';' => [], '[' => [], ']' => [], '`' => [],
             '{' => [], '}' => [], '+' => [], '-' => [], '*' => [], '/' => []}
  index = 0
  str.each_char do |c|
    if special.include?(c)
      special[c].push(index)
    end
    index += 1
  end
  special
end


def readInts()
  writeTo = File.open('lexed.txt', 'w')
  File.open('fileToLex.txt', 'r').each_line do |line|

      # For each line we split the elements by the whitespace.
      line.split.each do |item|
          index = 0
          queue = []

          # Because special characters do not require whitespace with respect to location relative to operands.
          findSpecial(item).each do |key, val|

            # We see where the special characters are located and push them to a queue.
            pos = 0
            val.each do |v|

              # If it is the first element then it will be written first.
              # Need to account for multiple special characters being started in a row.
              if v == pos
                pos += 1
                writeTo.write('s ' + key + "\n")
              else
                queue.push('s ' + key + "\n")
              end

              # We have queued the items so we create whitespace and resplit the list of the new non-special operands.
              item[v] = ' '
            end
          end
          item = item.split

          item.each do |it|

            # I'm going to say there are only single line comments for initial simplicities sake.
            # This means that when a comment character is found, the rest of the line may be ignored (can't break out of a comment).
            if (index = it.is_a_comment?) != 0
              it = it[0, index - 1].to_s
            end


            # We still need to write because this separation could have had information before a comment.
            if it.length != 0
              if it.is_a_int?
                  postFix = it.include?('.') ? 'f' : 'i'
                  writeTo.write(postFix + ' ' + it + " \n")
              else
                writeTo.write('v ' + it + "\n")
              end
            end

            # If we found a comment we break.
            if index != 0
              break
            end

            # Idea to go operand and then special character.

            # TODO : problem, what if I have: hello()
            if queue.length > 0
              writeTo.write(queue.shift)
            end

          end

          # If we found a comment we break.
          if index != 0
            break
          end

          # Write whatever is left in the queue.
          writeTo.write(queue.shift) while queue.length > 0

        end
      end
  writeTo.close
end

readInts
