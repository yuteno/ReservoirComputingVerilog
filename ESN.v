module conventional_SCR_network(
	input wire [15:0] x_input,
	input wire [15:0] r_input,
	input wire [15:0] v1_input,
	input wire clk,
	input wire reset,
	output wire [15:0] out_x[0:50-1]
);

parameter N = 50;
wire [15:0] r;
wire [15:0] v[0:N-1];
wire [31:0] prod1[0:N-1], prod2[0:N-1];
wire [16:0] prod1b[0:N-1], prod2b[0:N-1];
wire [16:0] sum[0:N-1];

wire [15:0] v2_input;
reg [15:0] x_anterior[0:N-1];


assign v2_input = ~v1_input + 16'h0001;

integer j;
// assigning randomly for each neuron
generate
	genvar i;
	for(i=1; i < N; i=i+2) begin
		assign v[i] = v2_input;

	end

	for(i=0; i < N; i=i+2) begin
		assign v[i] = v1_input;

	end
endgenerate

initial begin
	for (j = 0; j < N; j = j + 1) begin
		x_anterior[j] <= (16'h0001 + j) % N;
	end
end

//interneuraonal connection is the same for all neurons
assign r = r_input;


//computation of the i-th neuron
generate
	for(i = 0; i < N; i = i+1) begin
		//first product
		assign prod1[i] = x_input * v[i];
		assign prod1b[i] = prod1[i][31:15];

		//second product
		assign prod2[i] = x_anterior[(N+i-1)%N] * r;
		assign prod2b[i] = prod2[i][31:15];

		//addition of the two previous term
		assign sum[i] = prod1b[i] + prod2b[i];
	end
endgenerate

//generate instances of tanh_approx
//assessment of the activation finction
generate
	for(i = 0; i < N; i = i + 1) begin
		tanh_approx i_tanh(.x(sum[i]), .f(out_x[i]));
	end
endgenerate



//registers holds the neuron output to be used in the next step
always@(posedge clk or posedge reset) begin
	for(j = 0; j < N; j = j+1) begin
		if (reset) begin
			x_anterior[j] <= 16'h0000;
		end
		else begin
			x_anterior[j] <= out_x[j];
		end
	end
end


endmodule


