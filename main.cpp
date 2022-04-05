#include<iostream>
#include<fstream>


extern "C" int turtle(char *dest_bitmap,
					char *commands,
					unsigned int commands_size);

using namespace std;

int main(void)
{
	unsigned int file_size = 90122;
	unsigned int Commands_size = 60;
	char *Dest_bitmap = NULL;
	Dest_bitmap = new char[file_size];
	char *Commands = NULL;
	Commands = new char[Commands_size];

	int result;

	ifstream input("input.bin", ios::in | ios::binary);
	if (!input)
	{
		cout << "Error while reading input.bin file" << endl;
		input.gcount();
		input.clear();
	}

	input.read(Commands, Commands_size);

	ifstream original("original.bmp", ios::in | ios::binary);
	if (!original)
	{
		cout << "Error while reading original.bmp file" << endl;
		original.gcount();
		original.clear();
	}

	original.read(Dest_bitmap, file_size);

	ofstream output("output.bmp", ios::out | ios::binary);
	if (!output)
	{
		cout << "Error while trying to create output.bmp" << endl;
		output.clear();
	}

	result = turtle(Dest_bitmap, Commands, Commands_size);

	cout << "Return: " << result << endl;

	output.write(Dest_bitmap, file_size); 

	//output.write(Commands, Commands_size); //For testing

	original.close();
	input.close();
	output.close();
	delete Commands;
	delete Dest_bitmap;
	//getchar(); //For testing
	return 0;
}
