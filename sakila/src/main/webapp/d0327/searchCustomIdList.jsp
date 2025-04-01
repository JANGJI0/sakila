<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import ="java.sql.*" %>
<%
   //로그인 session 검증
   	// 로그인 되었는지 아닌지?
	Integer staffId = (Integer)(session.getAttribute("loginStaff"));
			
	if(staffId == null) { // 로그인 안 한 상태라면
		response.sendRedirect("/sakila/index.jsp");
		return;
	}
   
   Integer inventoryId = Integer.parseInt(request.getParameter("inventoryId"));
   String searchName = request.getParameter("searchName");
   
   // 페이징
   int currentPage = 1;
   	if(request.getParameter("currentPage") != null) {
   		currentPage = Integer.parseInt(request.getParameter("currentPage"));
   	}
   	int rowPerPage = 10;
   	int startRow = (currentPage - 1) * rowPerPage;
   	
   
   Connection conn = null;
   PreparedStatement stmt = null;
   ResultSet rs = null;
   // 페이징 변수
   PreparedStatement stmt2 = null;
   ResultSet rs2 = null;
   
   
   String listSql = "select customer_id customerId, first_name firstName, last_name lastName, email, active from customer where concat(first_name, last_name) like ? ORDER BY customer_id LIMIT ?, ?";
   String countSql = "select count(*) cnt FROM customer where concat(first_name, last_name) like ?";
   Class.forName("com.mysql.cj.jdbc.Driver");
   conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila","root","java1234");
   stmt = conn.prepareStatement(listSql);
   stmt2 = conn.prepareStatement(countSql);
   stmt.setString(1, "%"+ searchName + "%");
   stmt.setInt(2, startRow);
   stmt.setInt(3, rowPerPage);
   stmt2.setString(1, "%"+ searchName + "%");
   
   //디버깅
   System.out.println(stmt);
  
   rs = stmt.executeQuery();
   rs2 = stmt2.executeQuery();
   
   // 전체페이지
   int totalCnt = 0;
   if(rs2.next()) {
	   	totalCnt = rs2.getInt("cnt");
   }
   int lastPage = totalCnt /rowPerPage;
   if(totalCnt % rowPerPage != 0) {
	   lastPage++;
   }
	
   	// 디버깅 전체 행 수 출력 확인
	System.out.println("전체 행의 수: " + rs2.getInt("cnt"));
   	
   	// 페이징 수 나타내기
   	int pageCount = 5;
   	int startPage = ((currentPage - 1) / pageCount) * pageCount + 1;
   	int endPage = startPage + pageCount -1;
   	if(endPage > lastPage) {
   		endPage = lastPage;
   	}
%>



<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title></title>
</head>
<body>
<style>
		 .nolink {  /*링크 밑줄 제거 */
		 	text-decoration: none;
		 	color: black; /* 필요시 색상 지정 */
		 }
		 
		 	.nolink:hover {
		 		color: #FF0000; /* 마우스 오버 시 색상 변경 (빨강)*/
		 	}
		 	/*border말고 다른 테이블 코드*/
	 	table {
	 		width: 50%;
	 		border-collapse: separate; /* 중요: collapse명 둥글게 안 보임*/
	 		border-spacing: 50;		/* 셀 간격*/
	 		border-radius: 5px;		/* 둥근 모서리*/	
	 		overflow: hidden;        /* 꼭 필요: 둥근 모서리가 잘리지 않게*/
	 		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); /* 그림자도 예쁘게*/
	 		border: 2px solid #ccc;
	 	}	
	 	th, td {
	 		padding: 12px 16px;
	 		text-align: left;
	 		background-color: #fff;
	 		border: 1px solid #bbb;
	 	}
	 	
	 	th {
	 		background-color: #f4F4F4;
	 		font-weight: bold;
	 		color: #000;
	 	}
	 	
	 	th:nth-child(even) {
	 		background-color: #f9f9f9;
	 	}
	 	
	 	th:hover {
	 		background-color: #eef6ff;
	 	}
	 	
	</style>
		<a href="/sakila/d0327/inventoryList.jsp">[inventoryList]</a>
	<table>
		<tr>
			<th>customerId</th>
			<th>firstName</th>
			<th>lastName</th>
			<th>email</th>
			<th>active</th>
			<th>선택</th>
		</tr>
		
		<%
			while(rs.next()) {
		%>
				<tr>
					<td><%=rs.getInt("customerId") %></td>
					<td><%=rs.getString("firstName") %></td>
					<td><%=rs.getString("lastName") %></td>
					<td><%=rs.getString("email") %></td>
					<td><%=rs.getInt("active") %></td>
					<td>
						<%
						 if(rs.getInt("active") == 0) {
						%>
							<a href='/sakila/d0327/updateCustomerActive.jsp?active=<%=rs.getInt("active")%>&customerId=<%=rs.getInt("customerId")%>'> 휴면상태 해지</a><!-- customer.active 0을 1로 변경 -->
						<%
						 	} else {
						%>
							<a href='/sakila/d0327/insertRentalForm.jsp?customerId=<%=rs.getInt("customerId")%>&inventoryId=<%=inventoryId%>'>선택</a>
						<%
						 	}
						%>
					</td>
				</tr>
		<%
			}
		%>
	</table>
	<!-- 페이징 -->
	<a href="/sakila/d0327/searchCustomIdList.jsp?currentPage=1&inventoryId=<%=inventoryId%>&searchName">[처음]</a>	
	<%
		// 10개 이전 할 경우
		if(currentPage > 1) {
			int prevPage = currentPage - 10;
			if(prevPage < 1) prevPage = 1;
	%>
		<a href="/sakila/d0327/searchCustomIdList.jsp?currentPage=<%=prevPage%>&inventoryId=<%=inventoryId%>&searchName">[이전]</a>	
	<%
		}
			for(int i = startPage; i<= endPage; i++) {
	%>
		<a href="/sakila/d0327/searchCustomIdList.jsp?currentPage=<%=i%>&inventoryId=<%=inventoryId%>&searchName">[<%=i %>]</a>	
	<%
		}
			// 10개 다음 할 경우
			if(currentPage < lastPage) {
				int nextPage = currentPage + 10;
				if(nextPage > lastPage) nextPage = lastPage;
	%>
		<a href="/sakila/d0327/searchCustomIdList.jsp?currentPage=<%=nextPage%>&inventoryId=<%=inventoryId%>&searchName">[다음]</a>	
	<%
		}
	%>
		<a href="/sakila/d0327/searchCustomIdList.jsp?currentPage=<%=lastPage%>&inventoryId=<%=inventoryId%>&searchName">[마지막]</a>	
</body>
</html>








