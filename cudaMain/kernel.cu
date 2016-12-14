
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdlib.h>
#include <stdio.h>
#include <io.h>
#include <string.h>
#include <vector>
#include <iostream>
#include <fstream>
#include <string>


#include "C:\Program Files\boost_1_62_0\boost\asio\buffer.hpp"
#include "C:\Program Files\boost_1_62_0\boost\asio.hpp"
#include "C:\Program Files\boost_1_62_0\boost\system\error_code.hpp"
#include "Dependencies\glew\glew.h"
#include "Dependencies\freeglut\freeglut.h"



using namespace boost::asio::ip;
std::string stock;
std::fstream temp_stream;

const int window_height = 720; 
const int window_width = 1280; 
int days_read = 0; 
float max_close_price = 0.0; 
float min_close_price = 9999999999.99; 
float max_result = -999999999.99, min_result = 999999999.99; 



class data_t
{
public:
	float open;
	float high;
	float low;
	float close;
	float volume;
	float adj_close;
	char date[12];
};


std::vector<data_t> prices;

float * results;

GLuint program;
GLint attribute_coord2d;

void print_text()
{
	glColor3f(0, 0, 0);
	glRasterPos2f(-0.5, -0.5);
	int i;
	char price_buffer[10]; 
	char idx_buffer[64]; 
	char label[64]; 
	sprintf(label, "PRICE OF %s", stock.c_str());

	glRasterPos2f(-0.145,0.9);
	for (size_t j = 0; j < strlen(label); j++)
	{
		glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, label[j]);
	}
	
	glColor3f(1.0, 0, 0);
	glRasterPos2f(-0.16, -0.1);
	char label2[64];
	sprintf(label2, "ON BALANCE VOLUME OF %s", stock.c_str());
	for (size_t j = 0; j < strlen(label2); j++)
	{
		glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, label2[j]);
	}
	
	for (float i = 0; i < 7; i++)
	{
		float p = min_close_price + (max_close_price - min_close_price)*i / 6.0; 
		sprintf(price_buffer, "%.2f", p);
		glColor3f(0, 0, 0);

		glRasterPos2f(-0.9, 0.2 + 0.1 * i);
		for (size_t j = 0; j < strlen(price_buffer); j++)
		{
			glutBitmapCharacter(GLUT_BITMAP_HELVETICA_10, price_buffer[j]);
		}

		p = min_result + (max_result - min_result)*i / 6.0;
		sprintf(idx_buffer, "%.2f", p);
		glColor3f(1.0, 0, 0);
		glRasterPos2f(-0.98, -0.8 + 0.1 * i);
		for (size_t j = 0; j < strlen(idx_buffer); j++)
		{
			glutBitmapCharacter(GLUT_BITMAP_HELVETICA_10, idx_buffer[j]);
		}

	}
	
	int day, idx = 0; 
	for (float f = -0.8; f <= 1.0; f += 0.4)
	{
		day = (days_read-1) / 4 * idx++; 
		glColor3f(0, 0, 0);
		glRasterPos2f(f-0.05, 0.12);
		for (size_t j = 0; j < strlen(prices[day].date); j++)
		{
			glutBitmapCharacter(GLUT_BITMAP_HELVETICA_10, prices[day].date[j]);
		}

		glColor3f(1.0, 0, 0);
		glRasterPos2f(f - 0.05, -0.88);
		for (size_t j = 0; j < strlen(prices[day].date); j++)
		{
			glutBitmapCharacter(GLUT_BITMAP_HELVETICA_10, prices[day].date[j]);
		}
	}
	
}
struct Point
{
	float x, y;
	unsigned char r, g, b, a;
};
std::vector< Point > points;
std::vector< Point > upper_coor;
std::vector <Point> result_points; 
std::vector <Point> lower_coor; 
void display(void)
{
	glClearColor(1.0, 1.0, 1.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	//glOrtho(-50, 50, -50, 50, -1, 1);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	// draw
	glColor3ub(255, 255, 255);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glVertexPointer(2, GL_FLOAT, sizeof(Point), &points[0].x);
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(Point), &points[0].r);
	glPointSize(3.0);
	glDrawArrays(GL_LINE_STRIP, 0, points.size());
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);


	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glVertexPointer(2, GL_FLOAT, sizeof(Point), &upper_coor[0].x);
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(Point), &upper_coor[0].r);
	glPointSize(3.0);
	glDrawArrays(GL_LINE_STRIP, 0, upper_coor.size());
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);



	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glVertexPointer(2, GL_FLOAT, sizeof(Point), &result_points[0].x);
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(Point), &result_points[0].r);
	glPointSize(3.0);
	glDrawArrays(GL_LINE_STRIP, 0, result_points.size());
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);



	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glVertexPointer(2, GL_FLOAT, sizeof(Point), &lower_coor[0].x);
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(Point), &lower_coor[0].r);
	glPointSize(3.0);
	glDrawArrays(GL_LINE_STRIP, 0, lower_coor.size());
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);



	print_text();

	glFlush();
	glutSwapBuffers();
}

void reshape(int w, int h)
{
	glViewport(0, 0, w, h);
}





__global__ void GPU_computation(data_t * prices, float * results, int offset)
{
	int i = threadIdx.x + offset;
	if (i == 0) results[i] = 0; 
	else
	{
		if (prices[i].close > prices[i - 1].close) results[i] = prices[i].volume;
		else if (prices[i].close < prices[i - 1].close) results[i] = -prices[i].volume;
		else results[i] = 0; 
	}
}

cudaError_t generate_cuda(std::vector<data_t> &prices, float * results);


void read_from_internet()
{
	std::cout << "Enter the symbol of a stock in capital letters" << std::endl;
	std::cout << "Enter the starting and ending data in the following format:" << std::endl;
	std::cout << "fasdf " << std::endl;
	std::cout << "Invalid input has undefined behavior" << std::endl;
	std::cin >> stock;
	int start_month, start_date, start_year, end_month, end_date, end_year;
	scanf("%d %d %d %d %d %d", &start_month, &start_date, &start_year, &end_month, &end_date, &end_year);
	std::cout << start_month << " " << start_date <<" " << start_year <<" " << end_month << " " << end_date<<" "  << end_year << std::endl; 
	stock[stock.length()] = 0; 

	start_month--; end_month--; 
	//int start_month = 1, start_date = 13, start_year = 2016, end_month = 10, end_date = 13, end_year = 2016;

	boost::system::error_code error;

	boost::asio::io_service io_service;
	tcp::socket socket(io_service);
	tcp::resolver resolver(io_service);
	tcp::resolver::query query("chart.finance.yahoo.com", "http");
	tcp::resolver::iterator i = resolver.resolve(query);
	boost::asio::connect(socket, i);
	boost::asio::streambuf request, response;
	std::ostream request_stream(&request);
	request_stream << "GET /table.csv?s=" << stock << "&a=" << start_month << "&b="
		<< start_date << "&c=" << start_year << "&d=" << end_month << "&e="
		<< end_date << "&f=" << "2016" << "&g=d&ignore=.csv HTTP/1.1\r\nHost: chart.finance.yahoo.com\r\n\r\n";

	boost::asio::write(socket, request);
	std::istream response_stream(&response);


	temp_stream.open("temp.txt", std::fstream::in | std::fstream::out | std::fstream::trunc);

	char buffer[4096];
	char start_sign[8];
	int start_flag = 0;
	sprintf(start_sign, "%d-", end_year);
	char temp[10];
	temp[8] = 0;
	for (int k = 0; k < 1000000; k++)
	{
		size_t x = boost::asio::read_until(socket, response, "\n", error);
		response_stream.getline(buffer, x);
		std::cout << buffer << std::endl;
		if (strlen(buffer) < 5 && start_flag) break;
		if (!start_flag) {
			memcpy(temp, buffer, 5);
			temp[5] = 0;
			if (strcmp(temp, start_sign) == 0) {
				start_flag = 1;
				temp_stream << buffer << "\n";
				days_read++; 
				std::cout << buffer << std::endl;
			}
		}
		//else std::cout << buffer << std::endl;
		else { temp_stream << buffer << "\n"; days_read++;  std::cout << buffer << std::endl;
		}

		//memcpy(temp, buffer + 2, 8);

	}
	temp_stream.seekp(0);
}

void read_prices(std::vector<data_t> & prices)
{
	data_t * temp = new data_t();
	std::string str;
	const char * ptr = NULL;
	int i = 0;
	while (std::getline(temp_stream, str))
	{
		ptr = str.c_str();

		memcpy(temp->date, ptr, 10);

		temp->date[10] = 0;
		ptr = strchr(ptr, ',') + 1;
		temp->open = atof(ptr);

		ptr = strchr(ptr, ',') + 1;
		temp->high = atof(ptr);

		ptr = strchr(ptr, ',') + 1;
		temp->low = atof(ptr);

		ptr = strchr(ptr, ',') + 1;
		temp->close = atof(ptr);

		if (max_close_price < temp->close) max_close_price = temp->close; 
		if (min_close_price > temp->close) min_close_price = temp->close; 

		ptr = strchr(ptr, ',') + 1;
		temp->volume = atoi(ptr);

		ptr = strchr(ptr, ',') + 1;
		temp->adj_close = atof(ptr);


		prices.push_back(*temp);
	}
	free(temp);
	temp_stream.close();
	//fb.close();
	temp = NULL;
	return;
}

int glut_window(int argc, char ** argv)
{
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_RGBA | GLUT_DEPTH | GLUT_DOUBLE);

	glutInitWindowSize(window_width, window_height);
	glutCreateWindow("Random Points");

	glutDisplayFunc(display);
	glutReshapeFunc(reshape);

	// populate points
	for (size_t i = 0; i < days_read; ++i)
	{
		Point pt;
		pt.x = (float) i / (float) days_read * 1.6 - 0.8;
		pt.y = (prices[i].close - min_close_price) / (max_close_price - min_close_price) * 0.6 + 0.2;
		pt.r = 0;
		pt.g = 0;
		pt.b = 0;
		pt.a = 255;
		points.push_back(pt);
	}
	for (int l = 0; l < 1; l++) {
		Point pt1, pt2, pt3;

		pt1.x = -0.85;
		pt1.y = 0.85;
		pt1.r = 0;
		pt1.g = 0;
		pt1.b = 0;
		pt1.a = 255;

		pt2.x = -0.85;
		pt2.y = 0.15;
		pt2.r = 0;
		pt2.g = 0;
		pt2.b = 0;
		pt2.a = 255;

		pt3.x = 0.85;
		pt3.y = 0.15;
		pt3.r = 0;
		pt3.g = 0;
		pt3.b = 0;
		pt3.a = 255;
		upper_coor.push_back(pt1);
		upper_coor.push_back(pt2);
		upper_coor.push_back(pt3);
	}
	for (size_t i = 0; i < days_read; ++i)
	{
		Point pt;
		pt.x = (float)i / (float)days_read * 1.6 - 0.8;
		pt.y = (results[i] - min_result) / (max_result - min_result) * 0.6 - 0.8;
		pt.r = 255;
		pt.g = 0;
		pt.b = 0;
		pt.a = 255;
		result_points.push_back(pt);
	}

	for (int l = 0; l < 1; l++) {
		Point pt1, pt2, pt3;

		pt1.x = -0.85;
		pt1.y = -0.15;
		pt1.r = 255;
		pt1.g = 0;
		pt1.b = 0;
		pt1.a = 255;

		pt2.x = -0.85;
		pt2.y = -0.85;
		pt2.r = 255;
		pt2.g = 0;
		pt2.b = 0;
		pt2.a = 255;

		pt3.x = 0.85;
		pt3.y = -0.85;
		pt3.r = 255;
		pt3.g = 0;
		pt3.b = 0;
		pt3.a = 255;
		lower_coor.push_back(pt1);
		lower_coor.push_back(pt2);
		lower_coor.push_back(pt3);
	}




	glutMainLoop();
	return 0;
}

void process_results()
{
	// for OBV
	for (int i = 1; i < prices.size(); i++) {
		results[i] += results[i - 1]; 
		if (results[i] > max_result) max_result = results[i]; 
		if (results[i] < min_result) min_result = results[i]; 
	}
}

int main(int argc, char** argv)
{

	read_from_internet();
	
	read_prices(prices);
	std::reverse(prices.begin(), prices.end());
	results = (float*) calloc(prices.size(), sizeof(float));

	generate_cuda(prices, results);



	std::cout << "the size of the vector is" << prices.size() << std::endl;
	process_results(); 

	std::cout << results[5] << " " << results[120] << " " << std::endl;
	int d; 
	printf("finished\n");

	glut_window(argc, argv);

	scanf("%d", &d); 
	 


	return 0;
}


// Helper function for using CUDA to add vectors in parallel.

cudaError_t generate_cuda(std::vector<data_t> &prices, float * results)
{
	data_t * price_array = NULL;
	size_t days = prices.size();
	float * dev_results = NULL; 
	cudaMalloc((void**)&price_array, days * sizeof(data_t));
	cudaMalloc((void**)&dev_results, days*sizeof(float));
	cudaMemcpy(price_array, &(prices[0]), days * sizeof(data_t), cudaMemcpyHostToDevice);
	cudaError_t cudaStatus; 
	for (size_t i = 0; i < days; i += 250)
	{
		if (days - i >= 250)
		{
			GPU_computation << <1, 250 >> >(price_array, dev_results, (int)i);
			cudaDeviceSynchronize();
		}
		else
		{
			GPU_computation << <1, days-i >> >(price_array, dev_results, (int)i);
			cudaDeviceSynchronize();
		}
	}
	cudaMemcpy(results, dev_results, sizeof(float)*days , cudaMemcpyDeviceToHost); 
	cudaFree(dev_results);
	cudaFree(price_array);
	return cudaSuccess;
}

