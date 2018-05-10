require 'json'
=begin
#Hard coded implementation
test = "test"
codes = Hash["t" => 0, "e" => 10, "s" => 110 ]    #codes that would be genereated from the Huffman Tree
test.split("").each do |i|                        #Loops through each character in the String
  print codes[i].to_s + " "                       #"Looks up" the key in the hash and, if found, it will print out its code(a binary digit)
end

testCodes = "0 10 110 0"                          #The encoded string
testCodes.split(" ").each do |i|                  #Loop through and find the key associated for these values
  print codes.key(i.to_i) + " "                   #prints out the value if found
end
=end


#Code to generate a Freqeuncy table for a given String
def genFreqTable(string)
  freqTable = Hash.new
  string.split("").each do |i|                       #loop through every character in the string
    if freqTable.has_key?(string[i])                 #if key already exists
      freqTable[string[i]] += 1                      #increments its frequency
    else
      freqTable[string[i]] = 1                       #else its a new key so set its frequency to 1
    end
  end
  return freqTable
end

#This class will act as the nodes in the Huffman Tree
class HuffNode
  attr_accessor(:char, :value, :left, :right)
  def initialize(c, val, l, r)
    @char = c
    @value = val
    @left = l
    @right = r
  end
end

#Code to generate Huffman Tree given a Frequency Table
def genHuffmanTree(freqTable)
  freqTable = freqTable.sort_by {|_key, value| value}.to_h                                #Sort the table by the value(i.e. its frequency) in case it isn't already
  nodesArr = Array.new
  freqTable.each{|key,value| nodesArr.push(HuffNode.new(key, value, nil, nil))}           #For each of the key-value pairs in the frequency table, createa a HuffNode and add it to an Array
  while nodesArr.length > 1 do
    node1 = nodesArr.delete_at(0)                                                         #Remove the top node and store it in node1
    node2 = nodesArr.delete_at(0)                                                         #Remove the (now)top node and store it in node2
    pNode = HuffNode.new(nil,node1.value + node2.value, node1, node2)                     #Create a parent node that will have node1 and node2 will be connected to its left and right branch, respectively.
    nodesArr.push(pNode)                                                                  #Also its data will be node1's value plus node2 value, store it in the Array
    nodesArr = nodesArr.sort{ |x, y| x.value <=> y.value}                                 #Sort the nodes
  end
  return nodesArr[0]                                                                      #Returns the root node where all the HuffNodes are its children
end

#Recursive method that will create the code table if given the root node of the Huffman Tree
def createCodeTable(root, code, codeTable)
  if root.right == nil && root.left == nil && root.char != nil     #if it is a leaf node
    return codeTable.store(root.char, code)                        #store the string and its code into the hash
  end
  createCodeTable(root.left, code + "0", codeTable)                #Recursively call the left and right side, as well as append a digit to the branch
  createCodeTable(root.right, code + "1", codeTable)
end

#Method that will convert a String into the code if given the string and the codeTable(assuming the code table has been set up for this string)
def convertStringToCode(string, codeTable)
  code = ""
  string.split("").each do |i|
      code += codeTable[i].to_s + " "
  end
  return code
end

#Method that will convert a code into the string if given the code and the codeTable(assuming the code table has been set up for this code)
def convertCodeToString(code, codeTable)
  string = ""
  code.split(" ").each do |i|
    string += codeTable.key(i).to_s                                  #This will return the key corresponding to the value split out of the code which represents one character
  end
  return string
end

#In the case where the user wants to enter in a file instead of just a text
def handleFileInput
  print "Enter the name of the file: "
  filename = gets.chomp                                             #Take in use input and get rid of newline
  txt = ""
  begin
    File.open(filename, "r") do |f|
      f.each_line do |line|
        txt += line
      end
    end
  rescue Exception => msg
    puts msg
  end
  return txt
end


#Method will be used to output Compressed file
def handleFileOutput(code)
  open('output.txt', 'w') do |f|
    f << code
  end
  puts "Compressed file successfully saved as output.txt\n\n"
end

#Method will be used to output Frequency Table
def outputFreqTable(fT)
  open('frequencyTable.json', 'w') do |f|
    f.write JSON.dump(fT)
  end
  puts "Frequency Table successfully saved as frequencyTable.json\n\n"
end

#Wil be used to decode an encoded file, but will only work if the correct frequencyTable.json is used (i.e. must encode the file first before you try to decode it, the frequencyTable.json gets overwritten each time a new input comes in)
def decodeFile
  encodedText = handleFileInput
  data = JSON.load(File.read("frequencyTable.json"))
  testRoot = genHuffmanTree(data)
  testTable = Hash.new
  createCodeTable(testRoot, "", testTable)
  puts "\nDecoded File: #{convertCodeToString(encodedText, testTable)}\n\n"
end


#Where everyyhing is actually called when it runs
begin
  print "Enter 1 if you want to enter a String, 2 to read in a file, or anything else to quit: "
  ans = gets.chomp.to_i
  if ans == 1
    print "Enter a String: "
    userInput = gets.chomp
  elsif ans == 2
    print "Is the file encoded?(y,n): "
    ans2 = gets.chomp
    if ans2 == "y" || ans2 == "yes" || ans2 == "yup" || ans2 == "yeah" || ans2 == "uhh maybe" ||  ans2 =="All I see is binary"
      decodeFile
      next
  end
    userInput = handleFileInput
  else
    break
  end

  frequencyTable = genFreqTable(userInput)

  puts "\nHuffman coding initialized".upcase!
  puts "-------------------------------------------------------------------------------"
  puts "\nThe Frequency Table: #{frequencyTable.sort_by {|_key, value| value}.to_h}\n\n"
  tree = genHuffmanTree(frequencyTable)
  outputFreqTable(frequencyTable)
  table = Hash. new
  createCodeTable(tree ,"", table)
  puts "The Code Table: #{table}\n\n"
  code = convertStringToCode(userInput, table)
  puts "The string encoded using the Code Table: #{code}\n\n"
  if ans == 2
    handleFileOutput(code)
  end
  print "The Code decoded using the Code Table: #{convertCodeToString(code, table)}\n\n"
  puts "-------------------------------------------------------------------------------"
end while true
